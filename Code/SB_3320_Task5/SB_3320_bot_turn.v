module SB_3320_bot_turn(
	input clk_50,
	input start,
	input sensor_l,
	input sensor_m,
	input sensor_r,
	input [2:0] turn,
	output done,
	output left_motor,
	output right_motor,
	output gndl,
	output gndr
	);
	
	
	reg done_temp=1'b0;

	reg [2:0]stop		=3'b000;
	reg [2:0]forward  =3'b001;
	reg [2:0]left		=3'b010;
	reg [2:0]right		=3'b011;
	reg [2:0]extreme  =3'b100;

	reg [2:0]turn_temp;
	
	wire[2:0]turn_t;
	
	
	
	
	
	always@(posedge clk_50)begin
	
	if(sensor_l && sensor_m && sensor_r)begin
	turn_temp=forward;
	end
	
	else
	
	case(turn)
	
	
					right  : begin
										  if(!sensor_l && !sensor_m && sensor_r)begin
										  done_temp=1'b1;
										  turn_temp=stop;
										  end
										  
										  else begin
													 turn_temp=turn;
													 done_temp=1'b0;
													  end
							   end
							  
							  
							 
							  
					left   : begin
									     if(sensor_l && !sensor_m && !sensor_r)begin
											done_temp=1'b1;
											turn_temp=stop;
										   end
											
											else begin
													 turn_temp=turn;
													 done_temp=1'b0;
													  end
							   end
							  
				  forward : begin
											if(!sensor_l && sensor_m && !sensor_r)begin
											  done_temp=1'b1;
											  turn_temp=stop;
											  end
											  
											  else begin
													 turn_temp=turn;
													 done_temp=1'b0;
													  end
							    end
								 
								 
				  extreme : begin
											if(sensor_l && !sensor_m && !sensor_r)begin
											  done_temp=1'b1;
											  turn_temp=stop;
											  end
											  
											  else begin
													 turn_temp=turn;
													 done_temp=1'b0;
													  end
							    end
				
					
								 
							  
					 
					 
endcase

end

assign done=(start)?done_temp:1'b0;					

assign turn_t = turn;

	
SB_3320_motor_control motor_control_obj(.clk_50(clk_50), .turn(turn_temp), .left_motor(left_motor), .right_motor(right_motor),
											.gndl(gndl), .gndr(gndr) );

	
	endmodule 