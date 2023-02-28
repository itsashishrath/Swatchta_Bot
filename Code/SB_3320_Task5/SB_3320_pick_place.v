module SB_3320_pick_place(
	input clk,
	input start,
	input [5:0]arm_movement,
	output arm,
	output up,
	output extend,
	output [1:0]done
);
parameter 
	arm_extend = 6'd0,
	arm_up = 6'd1,
	arm_open = 6'd2,
	pick = 6'd3,
	grab = 6'd4,
	arm_movement_pick=6'd0,
	arm_movement_place=6'd1;

	
reg [20: 0] counter;
reg [5:0] state = 6'd0;
reg [5:0] state_2 = 6'd0;
reg servo_arm;
reg servo_up;
reg servo_extend;
reg done_current;
reg [1:0] done_temp=2'd0;
reg [20:0] clock_counter;
reg [10:0] clk_wait;

always @ (posedge clk) if(start==1'b1)


begin


	counter <= counter + 21'd1;
	if(counter == 21'd999999)
		counter <= 21'd0;

case(arm_movement)

	arm_movement_place  : begin
									done_temp = 2'd0;
									
									case(state_2)
									
										arm_extend: begin
															clock_counter <= clock_counter + 1;
															if(clock_counter == 21'd999999) begin
																clock_counter <= 0;
																clk_wait <= clk_wait + 1;
															end
															if(clk_wait >= 11'd50 && done_current) begin
																clk_wait <= 11'd0;
																done_current <= 1'd0;
																state_2 <= arm_up;
															end
															
															//condition for arm to extend (extend == open)
															if(counter < 21'd99000)
																servo_extend <= 1'b1;
															else
																servo_extend <= 1'b0;
																
																
															//all of the remaing states
															if(counter < 21'd69000) 
																servo_arm <= 1'b1;
															else	
																servo_arm <= 1'b0;
																
															if(counter < 21'd75000)
																servo_up <= 1'b1;
															else	
																servo_up <= 1'b0;
																
															done_current <= 1'd1;
														end
										
										
									arm_up: 		begin
															clock_counter <= clock_counter + 1;
															if(clock_counter == 21'd999999) begin
																clock_counter <= 0;
																clk_wait <= clk_wait + 1;
															end
															if(clk_wait >= 11'd50 && done_current) begin
																clk_wait <= 11'd0;
																done_current <= 1'd0;
																state_2 <= arm_open;
															end
															
															//arm is geeting down (up = open)
															if(counter < 21'd101000)
																servo_up <= 1'b1;
															else	
																servo_up <= 1'b0;
															
															//all the remaing states
															if(counter < 21'd69000) 
																servo_arm <= 1'b1;
															else	
																servo_arm <= 1'b0;
																
															if(counter < 21'd99000)
																servo_extend <= 1'b1;
															else
																servo_extend <= 1'b0;
																
															done_current <= 1'd1;
														end
										
								arm_open: 	begin 
														clock_counter <= clock_counter + 1;
														if(clock_counter == 21'd999999) begin
															clock_counter <= 0;
															clk_wait <= clk_wait + 1;
														end
														if(clk_wait >= 11'd50 && done_current) begin
															clk_wait <= 11'd0;
															done_current <= 1'd0;
															state_2 <= 6'd8;
														end
														
														
														//arm claw is beign open up (arm == open)
														
														if(counter < 21'd85000) 
															servo_arm <= 1'b1;
														else	
															servo_arm <= 1'b0;
														
														
														//all the remaing states
														if(counter < 21'd99000)
															servo_extend <= 1'b1;
														else
															servo_extend <= 1'b0;
															
															
														if(counter < 21'd101000)
															servo_up <= 1'b1;
														else	
															servo_up <= 1'b0;
															
															
														done_current <= 1'd1;
														
													end
											
											
							 default: begin
											
												clock_counter <= clock_counter + 1;
														if(clock_counter == 21'd999999) begin
															clock_counter <= 0;
															clk_wait <= clk_wait + 1;
														end
														if(clk_wait >= 11'd50 && done_current) begin
															clk_wait <= 11'd0;
															done_current <= 1'd0;
															done_temp=2'd2;
														end
												
											
												if(counter < 21'd69000) 
													servo_arm <= 1'b1;
												else	
													servo_arm <= 1'b0;
													
													
												if(counter < 21'd72000)
													servo_extend <= 1'b1;
												else
													servo_extend <= 1'b0;
													
													
												if(counter < 21'd50000)
													servo_up <= 1'b1;
												else	
													servo_up <= 1'b0;
													
												done_current <= 1'd1;
													
													
											end
										
										
									endcase	
												  end
	
arm_movement_pick : begin
							done_temp = 2'd0;
									case(state)
									arm_open: begin
										clock_counter <= clock_counter + 1;
									if(clock_counter == 21'd999999) begin
										clock_counter <= 0;
										clk_wait <= clk_wait + 1;
									end
									if(clk_wait >= 11'd50 && done_current) begin
										clk_wait <= 11'd0;
										done_current <= 1'd0;
										state <= arm_extend;

									end
									
										if(counter < 21'd80000)
											servo_arm <= 1;
									else
										servo_arm <= 0;
										
									//state of arm close

									if(counter < 21'd75000)
											servo_up <= 1;
									else 
											servo_up <= 0;


									if(counter < 21'd72000)
											servo_extend <= 1;
									else 
											servo_extend <= 0;
									
									done_current <= 1'd1;
									
								end

									arm_extend: begin
									clock_counter <= clock_counter + 1;
									if(clock_counter == 21'd999999) begin
										clock_counter <= 0;
										clk_wait <= clk_wait + 1;
									end
									if(clk_wait >= 11'd50 && done_current) begin
										clk_wait <= 11'd0;
										done_current <= 1'd0;
										state <= pick;
									end
									
										if(counter < 21'd72000)
											servo_extend <= 1;
									else 
											servo_extend <= 0;
											
									//all other  state of arm
									
									if(counter < 21'd80000)
											servo_arm <= 1;
									else
										servo_arm <= 0;
										
										
									if(counter < 21'd75000)
											servo_up <= 1;
									else 
											servo_up <= 0;
											
										
									
									done_current <= 1'b1;
									
								end
									pick: begin
									clock_counter <= clock_counter + 1;
									if(clock_counter == 21'd999999) begin
										clock_counter <= 0;
										clk_wait <= clk_wait + 1;
									end
									if(clk_wait >= 11'd50 && done_current) begin
										clk_wait <= 11'd0;
										done_current <= 1'd0;
										state <= grab;

									end
								//	if(done_current) begin
								//		state <= grab;
								//		done_current <= 1'b0;
								//	end
									

										
									if(counter < 21'd96000)
											servo_up <= 1;
									else 
											servo_up <= 0;
											
									//all other state		
									if(counter < 21'd80000)
											servo_arm <= 1;
									else
										servo_arm <= 0;
										
									if(counter < 21'd72000)
											servo_extend <= 1;
									else 
											servo_extend <= 0;

											
									done_current <= 1'b1;		
									end
									
									grab: begin
									clock_counter <= clock_counter + 1;
									if(clock_counter == 21'd999999) begin
										clock_counter <= 0;
										clk_wait <= clk_wait + 1;
									end
									if(clk_wait >= 11'd50 && done_current) begin
										clk_wait <= 11'd0;
										done_current <= 1'd0;
										state <= 6'd8;

									end
									
								//		if(done_current) begin 
								//			state <=2'd2;
								//			done_current <= 1'd0;
								//		end
										if(counter < 21'd69000)
											servo_arm <= 1;
										else
											servo_arm <= 0;
											
										//all other state
										if(counter < 21'd72000)
											servo_extend <= 1;
									else 
											servo_extend <= 0;

										if(counter < 21'd96000)
											servo_up <= 1;
									else 
											servo_up <= 0;
										
										done_current <= 1'b1;
									
									end
									
									default : begin 
									
													clock_counter <= clock_counter + 1;
														if(clock_counter == 21'd999999) begin
															clock_counter <= 0;
															clk_wait <= clk_wait + 1;
														end
														if(clk_wait >= 11'd50 && done_current) begin
															clk_wait <= 11'd0;
															done_current <= 1'd0;
															done_temp=2'd1;
														end
														
														
									
													if(counter < 21'd50000)
														servo_up <= 1;
												else 
														servo_up <= 0;


												if(counter < 21'd72000)
														servo_extend <= 1;
												else 
														servo_extend <= 0;
														
												if(counter < 21'd69000)
														servo_arm <= 1;
													else
														servo_arm <= 0;
														
													done_current <= 1'd1;
									end
									

								endcase
								
								
									end
endcase
	


end


assign done = (start)? done_temp:2'd0; 
assign arm = servo_arm;
assign up = servo_up;
assign extend = servo_extend;


endmodule 