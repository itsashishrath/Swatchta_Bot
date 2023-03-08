module SB3320_Swatchta_bot(
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
	 output [2:0]bot_turns
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
			 line_follow_x=4'd9,
			 motor_follow_line=4'd0,
			 bot_turn_state=4'd1;


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

wire l_sensorz;

wire [4:0]previous_node_x;
wire [4:0]current_node_x;
wire [4:0]next_node_x;


reg [3:0]previous_node_counter;
reg [3:0]current_node_counter;
reg [3:0]next_node_counter;

reg [3:0] time_counter=4'd0;

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


reg [3:0] pos=4'd2;

reg [3:0] counter=4'd9;


reg [4:0]current_nodex=5'd30;

wire path_stored_complete_t;
reg  path_stored_complete=0;
assign path_stored_complete_t=path_stored_complete;


reg [4:0] s_node_store[2:0];
reg [4:0] e_node_store[2:0];

parameter stop		=3'b000,
			forward =3'b001,
			left		=3'b010,
			right	=3'b011,
			extreme=3'd100;

initial begin
	s_node_store[2]=5'd0;
   s_node_store[1]=5'd3;
   s_node_store[0]=5'd8;

   e_node_store[2]=5'd3;
   e_node_store[1]=5'd8;
   e_node_store[0]=5'd14;
end

SB3320_adc_control adc_control_obj( .clk_50(clk_50), .dout(dout), .adc_cs_n(adc_cs_n), .din(din), .adc_sck(adc_sck), .sensor_l(sensor_l),
											.sensor_m(sensor_m), .sensor_r(sensor_r) );

											
											
SB3320_path_planner path_planner_obj(.clk_50(clk_50), .start(path_plan_start), .s_node(s_node), .e_node(e_node), .done(path_plan_done),
										.final_path(path) );

										

SB3320_Run_motor Run_motor_obj( .clk_50(clk_50), .sensor_l(sensor_l), .sensor_m(sensor_m), .sensor_r(sensor_r), .turn(motor_turn), 
								 .l_motor(lmotortemp1), .r_motor(rmotortemp1), .motor_stopped(motor_stopped) );

								 
								 
SB3320_map_direction map_direction_obj(.clk_50(clk_50), .start(map_direction_start), .previous_node(previous_node),
											.current_node(current_node), .next_node(next_node), .direction(bot_turns));

											

SB3320_bot_turn bot_turn_obj(.start(motor_turn_start), .clk_50(clk_50), .sensor_l(sensor_l), .sensor_m(sensor_m), .sensor_r(sensor_r), .turn(bot_turns), .left_motor(lmotortemp2),
								.right_motor(rmotortemp2), 
								.done(bot_turn_done) 
								);
		
		assign gndl=(bot_turns==extreme && motor_turn_start)?1'b1:1'b0;
//		assign gndr=1'b0;
		assign gndr=1'b0;
		
		wire lmotortemp1;
		wire rmotortemp1;
		
		wire lmotortemp2;
		wire rmotortemp2;
		
		reg lmotortemp;
		reg rmotortemp;
	
		
		assign l_motor=lmotortemp;
		assign r_motor=rmotortemp;	
		
	
		always@(posedge clk_50)begin
		
		
		case(motor_turn_state)
		
		motor_follow_line	 : begin
										if(motor_turn==stop)begin
										motor_turn_start=1'b1;
										lmotortemp=lmotortemp2;
										rmotortemp=rmotortemp2;
										motor_turn_state=bot_turn_state;
										end
										
										else begin
										lmotortemp=lmotortemp1;
										rmotortemp=rmotortemp1;
										end
										
									end
									
		 bot_turn_state  : begin
		 
										if(bot_turn_done)begin
										motor_turn_start=1'b0;
										lmotortemp=lmotortemp1;
										rmotortemp=rmotortemp1;
										motor_turn_state=motor_follow_line;
										end
										
										else begin
										lmotortemp=lmotortemp2;
										rmotortemp=rmotortemp2;
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
													 state_temp<=6'd0;
                                        s_node=s_node_store[pos];
                                        e_node=e_node_store[pos];
													 path_plan_start=1'b1;
                                        state = path_forming;
                                      
                end
					 
					 path_forming     : begin
													
													if(f_path[0]==e_node)begin
													
													current_node=f_path[counter];
													state=path_planning;
													end
													
													else 
													begin
													state=path_forming;
													end
													

					 end
					
                path_planning : begin	 
													 if(current_node==27)begin
														  counter=counter-4'd1;
														  current_node=f_path[counter];
														  state=path_planning;
														  end	
														  
                                        else 
													 begin
													 
													 path_calculated=1'b1;
													 previous_node_counter=counter+4'd1;
													 current_node_counter=counter;
													 next_node_counter=counter-4'd1;
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
											if(current_node==e_node) begin 
											   pos= pos-4'd1;
												counter=counter+4'd9;
												state=path_start;
												end
											else begin
											counter=counter-4'd1;
											state=bot_turning;
											end
					end
					
					bot_turning  	: begin
					
										 if(bot_turn_done) begin
										  time_counter=4'd0;
										  state=line_follow;
										  map_direction_start=1'b0;
										  end
										  
										 else begin
										 state=bot_turning;
										 end
					end
					

					
					bot_direction :  begin
					
										  if(current_node==e_node) state = color_sensor_read ;
										  else state=line_follow;
					end
					

				 
					color_sensor_read :  begin
												state=color_sensor_read;

												
					end
endcase
end 

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
													
													if(f_path[9]==27)path_stored_complete=1;
end


assign l_sensorz=sensor_l;

endmodule 