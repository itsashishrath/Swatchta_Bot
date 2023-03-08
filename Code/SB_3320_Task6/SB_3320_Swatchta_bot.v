module SB_3320_Swatchta_bot(
	 input  clk_50,				//50 MHz clock
	 input  dout,				//digital output from ADC128S022 (serial 12-bit)
	 output adc_cs_n,			//ADC128S022 Chip Select
	 output din,					//Ch. address input to ADC128S022 (serial)
	 output adc_sck,			//2.5 MHz ADC clock
    output reset,
	 output sensor_l,
	 output sensor_m,
	 output sensor_r,
	 output [2:0]motor_turn,
	 output l_motor,
	 output r_motor,
	 output gndl,
	 output gndr,
	 output [2:0]bot_turns,
	 output done,
	 input start,
	 input clk50,OUT,rst_n,
	 output reg S0,
	 output reg S2,
	 output reg S3,
	 output S1,
	 output red_led,
	 output blue_led,
	 output green_led,
	 output reg [9:0] red,
	 output reg [9:0] green,
	 output reg [9:0] blue,
	 
	 output [3:0] state_status,
	 
	 output [1:0]arm_done,
	 output arm,
	 output up,
	 output extend,
	 
	 output [4:0]data_index,
	 
	 output white_red,
	 output white_green,
	 output white_blue,
	 
						//50 MHz clock
	
	 output tx		//UART transmit output
);


parameter initialise=4'd0,
          path_start=4'd1,
			 path_forming=4'd2,
			 path_planning=4'd3,
			 line_follow=4'd4,
			 update_counter=4'd5,
			 bot_turning=4'd6,
          bot_direction=4'd7,
			 color_sensor_read=4'd8,
			 pick=4'd9,
			 place=4'd10,
			 uart_read=4'd11,
			 stop_bot_state=4'd12,
			 
			 motor_follow_line=4'd0,
			 bot_turn_state=4'd1,
			 color_motor_state=4'd2,
			 
			 arm_movement_pick=6'd0,
			 arm_movement_place=6'd1,
			 arm_movemet_default=6'd2;		 
			 
	
reg arm_start=1'b0;
reg [5:0] arm_movement;

assign state_status=state;

reg gbi_found;

reg color_read_start;
wire color_read_done;

reg uart_read_start=1'b0;
wire uart_done;


	reg [7:0] identified_type=8'h4D;
	reg [7:0] block_number=8'h32;
	reg [7:0] dump_zone=8'h41;
	reg [2:0] action=3'd3; 				// 0 - pick, 1 - dump, 2 - identification

			 
reg motor_turn_start=1'b0;
reg [3:0] motor_turn_state=motor_follow_line;			 
reg [4:0]s_node;
reg [4:0]e_node;         
wire path_plan_done;
reg path_plan_start=1;
wire bot_turn_done;
wire [49:0] path;

wire motor_stopped;

reg [4:0]previous_node=5'd30; ///NODE CAN BE INITIALISED IN ALWAYS BLOCK ONLY....CANNOT BE DEFINED WITHOUT CLOCK
reg [4:0]current_node=5'd30;
reg [4:0]next_node=5'd30;

reg [7:0] white_red_duty=8'd0;
reg [7:0] white_green_duty=8'd0;
reg [7:0] white_blue_duty=8'd0;

wire white_red_led;
wire white_blue_led;
wire white_green_led;

wire red_led_temp1;
wire blue_led_temp1;
wire green_led_temp1;

reg red_led_temp;
reg green_led_temp;
reg blue_led_temp;

reg [2:0] led_status;

reg [7:0] gbi_hex_store[15:0];



reg path_calculated=1'b0;

reg map_direction_start=1'b0;

reg [5:0] state_temp;

reg [4:0]f_path[9:0];

reg [3:0]state = initialise;

reg follow_line_reset=0;


reg [2:0]bot_turns_x;

//always@(posedge clk_50)begin
//bot_turns_x=bot_turns;
//end
reg [9:0] ms_counter;
reg [20:0] time_counter;

reg dumped=1'b0;

reg [3:0] pos=4'd8;

reg [3:0] counter=4'd9;


reg [4:0]current_nodex=5'd30;

wire path_stored_complete_t;
reg  path_stored_complete=0;
assign path_stored_complete_t=path_stored_complete;


reg [4:0] s_node_store[8:0];
reg [4:0] e_node_store[8:0];

parameter stop		=3'b000,
			forward =3'b001,
			left		=3'b010,
			right	=3'b011,
			extreme=3'd100;

initial begin
	s_node_store[8]=5'd0;
   s_node_store[7]=5'd3;
   s_node_store[6]=5'd4;
	s_node_store[5]=5'd8;
	s_node_store[4]=5'd14;
	s_node_store[3]=5'd10;
	s_node_store[2]=5'd24;
	s_node_store[1]=5'd25;
	s_node_store[0]=5'd21;
	

   e_node_store[8]=5'd3;
   e_node_store[7]=5'd4;
   e_node_store[6]=5'd8;
	e_node_store[5]=5'd14;
	e_node_store[4]=5'd10;
	e_node_store[3]=5'd24;
	e_node_store[2]=5'd25;
	e_node_store[1]=5'd21;
	e_node_store[0]=5'd19;
	
	
	gbi_hex_store[7]=8'h31;
	gbi_hex_store[6]=8'h39;
	gbi_hex_store[5]=8'h32;
	gbi_hex_store[4]=8'h33;
	gbi_hex_store[3]=8'h38;
	gbi_hex_store[2]=8'h37;
	gbi_hex_store[1]=8'h36;
	gbi_hex_store[0]=8'h35;
	gbi_hex_store[15]=8'h34;
	
end



always@(posedge clk_50)begin
	
													if(red_led) begin
													identified_type<=8'h4D;
													dump_zone<=8'h41;
													end
													
													else if(blue_led ) begin
													identified_type<=8'h57;
													dump_zone<=8'h43;
													end
													
													else if(green_led ) begin
													identified_type<=8'h44;
													dump_zone<=8'h42;
													end
													
											block_number<=(gbi_found==1'b0)?gbi_hex_store[pos]: block_number;	
end


SB_3320_adc_control adc_control_obj( .clk_50(clk_50), .dout(dout), .adc_cs_n(adc_cs_n), .din(din), .adc_sck(adc_sck), .sensor_l(sensor_l),
											.sensor_m(sensor_m), .sensor_r(sensor_r) );

											
											
SB_3320_path_planner path_planner_obj(.clk_50(clk_50), .start(path_plan_start), .s_node(s_node), .e_node(e_node), .done(path_plan_done),
										.final_path(path) );

										

SB_3320_Run_motor Run_motor_obj( .clk_50(clk_50), .sensor_l(sensor_l), .sensor_m(sensor_m), .sensor_r(sensor_r), .turn(motor_turn), 
								 .l_motor(lmotortemp1), .r_motor(rmotortemp1), .motor_stopped(motor_stopped) );

								 
								 
SB_3320_map_direction map_direction_obj(.clk_50(clk_50), .start(map_direction_start), .previous_node(previous_node),
											.current_node(current_node), .next_node(next_node), .direction(bot_turns));

											

SB_3320_bot_turn bot_turn_obj(.start(motor_turn_start), .clk_50(clk_50), .sensor_l(sensor_l), .sensor_m(sensor_m), .sensor_r(sensor_r), .turn(bot_turns), 
								.left_motor(lmotortemp2), .right_motor(rmotortemp2), .done(bot_turn_done), .gndl(gndltemp2), .gndr(gndrtemp2) 
								);

SB_3320_color_sensor color_sensor_obj(.start(color_read_start), .done(color_read_done), .rst_n(rst_n),.clk50(clk_50),.S0(S0),.S1(S1),.S2(S2),.S3(S3),.OUT(OUT),
										.red(red),.green(green), .blue(blue),.clk_0_1(clk_0_1),.clk_new(clk_new), .red_led(red_led_temp1), .blue_led(blue_led_temp1), 
										.green_led(green_led_temp1), .message(message_temp));

SB_3320_pick_place pick_place_obj(.start(arm_start), .done(arm_done), .clk(clk_50), .arm(arm), .up(up), .extend(extend), .arm_movement(arm_movement) );

SB_3320_uart uart_obj(.uart_start(uart_read_start), .clk_50M(clk_50), .it(identified_type), .bn(block_number), .dz(dump_zone), .action(action), .rst_n(rst_n), .tx(tx), .done(uart_done), .data_index(data_index) );

//		assign gndl=(bot_turns==extreme && motor_turn_start)?1'b1:1'b0;
//		assign gndr=1'b0;

		wire lmotortemp1;
		wire rmotortemp1;
		wire gndltemp1=1'b0;
		wire gndrtemp1=1'b0;
		
		wire lmotortemp2;
		wire rmotortemp2;
		wire gndltemp2;
		wire gndrtemp2;
		
		reg lmotortemp;
		reg rmotortemp;
		reg gndltemp;
		reg gndrtemp;
	
		
		assign l_motor=lmotortemp;
		assign r_motor=rmotortemp;
		assign gndl=gndltemp;
		assign gndr=gndrtemp;
		
		
	
		always@(posedge clk_50)begin
		
		
		case(motor_turn_state)
		
		motor_follow_line	 : begin
										
										if(motor_turn==stop && next_node==e_node) begin motor_turn_state=color_motor_state; end
										
										else if(motor_turn==stop )begin  	//yahan error ho skta hai ek...iss clock pe update hoga ya rukega
										motor_turn_start=1'b1;				 	//agar bot nhi ruke aur turn hone lage toh (if node change kr dena)
										lmotortemp=lmotortemp2;
										rmotortemp=rmotortemp2;
										gndltemp=gndltemp2;
										gndrtemp=gndrtemp2;
										motor_turn_state=bot_turn_state;
										end
										
										else begin
										lmotortemp=lmotortemp1;
										rmotortemp=rmotortemp1;
										gndltemp=gndltemp1;
										gndrtemp=gndrtemp1;
										end
										
									end
									
									
		color_motor_state : begin
									if(state == bot_turning) begin
										motor_turn_start=1'b1;
										lmotortemp=lmotortemp2;
										rmotortemp=rmotortemp2;
										gndltemp=gndltemp2;
										gndrtemp=gndrtemp2;
										motor_turn_state=bot_turn_state;
										end
										
									else  begin
											lmotortemp=lmotortemp1;
											rmotortemp=rmotortemp1;
											gndltemp=gndltemp1;
											gndrtemp=gndrtemp1;
											motor_turn_state=color_motor_state;
											end
								  end
									
		 bot_turn_state  : begin
		 
										if(bot_turn_done)begin
										motor_turn_start=1'b0;
										lmotortemp=lmotortemp1;
										rmotortemp=rmotortemp1;
										gndltemp=gndltemp1;
										gndrtemp=gndrtemp1;
										motor_turn_state=motor_follow_line;
										end
										
										else begin
										lmotortemp=lmotortemp2;
										rmotortemp=rmotortemp2;
										gndltemp=gndltemp2;
										gndrtemp=gndrtemp2;
										end
									
									
									end
endcase		
		 	
end
		

		
	

always@(posedge clk_50)begin
    case(state) 
	 
					 initialise    : begin
											state=path_start;
					end

                path_start    : begin 	
					 
													 if(gbi_found)begin
													 if(red_led) e_node=5'd7;
													 else if(blue_led) e_node=5'd17;
													 else if(green_led)e_node=5'd11;
													 path_plan_start<=1'b1;
                                        state <= path_forming;
													 end
													 
													 else if(dumped)begin
													 e_node<=e_node_store[pos];
													 led_status=2'b0;
													 path_plan_start<=1'b1;
                                        state <= path_forming;
													 end
													 
													 else begin
                                        s_node=s_node_store[pos];
                                        e_node=e_node_store[pos];
													 path_plan_start=1'b1;
                                        state = path_forming;
													 end
                                      
                end
					 
					 path_forming     : begin
													
													if(f_path[0]==e_node)begin
													
													current_node=f_path[counter];
													state=path_planning;
													end
													
													else 
													begin
													dumped=1'b0;
													state=path_forming;
													end
													

					 end
					
                path_planning : begin	 
													 if(current_node==5'd27)begin
														  counter=counter-4'd1;
														  current_node=f_path[counter];
														  state=path_planning;
														  end
														  
                                        else
													 begin
													 path_calculated=1'b1;
													 if(pos!=4'd8) begin counter=counter-4'd1; end
													 state = line_follow;
													 end
                end
					 


                line_follow :   	begin 
										
											 if(motor_turn==stop)
																	begin
																	previous_node = f_path[counter+4'd1];
																	current_node = f_path[counter];
																	next_node  = f_path[counter-4'd1];
																	map_direction_start=1'b1;
																	state=update_counter;
																	end
																	
											else begin
											state=line_follow;
											end
										
					end
					
					update_counter : begin
											if(current_node==e_node && gbi_found)begin
											state=place;
											gbi_found=1'b0;
											arm_movement=arm_movement_place;
											counter=4'd9;
											end
											
											else if(current_node==e_node) begin 
											   pos = pos-4'd1;
												counter=4'd9;
												color_read_start=1'b1;
												state=color_sensor_read;
												end
												
											else begin
											counter=counter-4'd1;
											state=bot_turning;
											end
					end
					
					bot_turning  	: begin
										 
											
										  if(bot_turn_done) begin
											  if(current_node==e_node) begin state=path_start;  s_node=e_node; end
											  else  begin state=line_follow;  end
										 map_direction_start=1'b0;
										 end
										  
										 else begin
										 state=bot_turning;
										 end
					end
					

					
//					bot_direction :  begin
//					
//										  if(current_node==e_node) state = color_sensor_read ;
//										  else state=line_follow;
//					end
					


					color_sensor_read :  begin
												if(color_read_done)begin
													color_read_start=1'b0;
													led_status=2'd1;
													gbi_found=1'b1;
													uart_read_start<=1'b1;
													action<=3'd2;
													time_counter<=21'd0;
													ms_counter<=10'd0;
													state=uart_read;
													
												end
												
												else begin
													time_counter<=time_counter+21'd1;
													if(time_counter==21'd999999)begin
													time_counter<=21'd0;
													ms_counter<=ms_counter+10'd1;
													end
													
													if(ms_counter>10'd300)begin
													time_counter<=21'd0;
													ms_counter<=10'd0;
													state = bot_direction;
													color_read_start<=1'b0;
													end
													
													led_status=2'b0;
													
													
													
												end
					
												
					end
					
					
					bot_direction  : begin
											if(pos==4'd15 && led_status==2'b0) state=stop_bot_state;
											
											else state=bot_turning;
					end
					
					
					
					uart_read  		:  begin
											if(uart_done)begin
											
													uart_read_start=1'b0;
											
													if(action==3'd2) begin 
																			arm_start=1'b1; 
																			arm_movement=arm_movement_pick;
																			action<=3'd0;
																			state=pick; end
																			
													else if(action==3'd1 && pos==4'd15) begin  state=stop_bot_state; end
																			
													else if(action==3'd1) begin led_status=2'd0; state=bot_turning; end
													
													else if(action==3'd0) begin state=bot_turning; end
													
													
													
													
													
											end
											else begin
											state=uart_read;
											end
					end
					
					
					pick					: begin
					
													if(arm_done==2'd1)begin
													uart_read_start<=1'b1;
													
//													action<=3'd0;
													state=uart_read;
													end
													
													else begin
														
														state=pick;
													end
														
											  end
			      
					place					: begin
					
											  if(arm_done==2'd2)begin
												arm_start=1'b0;
												action=3'd1;
												uart_read_start=1'b1;
												dumped=1'b1;
												arm_movement=arm_movemet_default;
												gbi_found=1'b0;
												state=uart_read;
											  end
											  
											  else begin
													arm_start=1'b1;
													state=place;
												end
					end
					
					
					stop_bot_state : begin
											led_status=2'd2;
											
													time_counter<=time_counter+21'd1;
													if(time_counter==21'd999999)begin
													time_counter<=21'd0;
													ms_counter<=ms_counter+10'd1;
													end
													
													if(ms_counter>10'd100)begin
													time_counter<=21'd0;
													ms_counter<=10'd0;
													end
													
													if(ms_counter>50)begin
													white_red_duty=8'd25;
													white_green_duty=8'd25;
													white_blue_duty=8'd60;
													end
													else begin
													white_red_duty=8'd0;
													white_green_duty=8'd0;
													white_blue_duty=8'd0;
													end
													
											
											
											
					end
					
endcase
end 





always@(posedge clk_50)begin
	if(led_status==2'd0)begin
	red_led_temp=1'b0;
	green_led_temp=1'b0;
	blue_led_temp=1'b0;
	end
	
	if(led_status==2'd1)begin
	red_led_temp=red_led_temp1;
	green_led_temp=green_led_temp1;
	blue_led_temp=blue_led_temp1;
	end
	
	else if(led_status==2'd2)begin
	red_led_temp	=white_red_led;
	green_led_temp =white_green_led;
	blue_led_temp  =white_blue_led;
	end
	
end

assign red_led=red_led_temp;
assign green_led=green_led_temp;
assign blue_led=blue_led_temp;


SB_3320_PWM_Generator PWM_Generator_wr(.clk_50(clk_50), .duty_cycle(white_red_duty), .out(white_red_led) );
SB_3320_PWM_Generator PWM_Generator_wg(.clk_50(clk_50), .duty_cycle(white_green_duty), .out(white_green_led) );
SB_3320_PWM_Generator PWM_Generator_wb(.clk_50(clk_50), .duty_cycle(white_blue_duty), .out(white_blue_led) );


assign white_red=white_red_led;
assign white_green=white_green_led;
assign white_blue=white_blue_led;



always@(posedge path_plan_done)begin													
													f_path[9] = path[49:45];
													f_path[8] = path[44:40];
													f_path[7] = path[39:35];
													f_path[6] = path[34:30];
													f_path[5] = path[29:25];
													f_path[4] = path[24:20];
													f_path[3] = path[19:15];
													f_path[2] = path[14:10];
													f_path[1] = path[9:5];
													f_path[0] = path[4:0];
													
end


endmodule 