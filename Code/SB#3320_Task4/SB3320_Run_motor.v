module SB3320_Run_motor(
	input  reset,
	input  clk_50,
	output l_motor,
	output r_motor,
	output gndl,
	output gndr,
	input sensor_l,
	input sensor_m,
	input sensor_r,
	output [2:0]turn,
	output motor_stopped
	);
	
		wire [2:0]stop		=3'b000;
		wire [2:0]forward =3'b001;
		wire [2:0]left		=3'b010;
		wire [2:0]right	=3'b011;
	
		
		
		
	   assign motor_stopped =(turn==stop)?1:0;
											
		SB3320_line_run line_run_obj( .clk_50(clk_50), .sensor_1(sensor_l), .sensor_2(sensor_m), .sensor_3(sensor_r) , .turn(turn) );
		
		
		SB3320_motor_control motor_control_obj1(.clk_50(clk_50), .turn(turn), .left_motor(l_motor), .right_motor(r_motor) );
				
		
		
endmodule 