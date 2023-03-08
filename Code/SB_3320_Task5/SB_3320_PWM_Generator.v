// SB : Task 1 D PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 50Mhz Clock Frequency to 1Mhz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : .clk_50(clk_50), DUTY_CYCLE
//Output : PWM_OUT

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////

module SB_3320_PWM_Generator(
 
	input clk_50,             // Clock input
	input [7:0]duty_cycle, // Input Duty Cycle
	output out         // Output PWM
);
 
////////////////////////WRITE YOUR CODE FROM HERE////////////////////

   reg[29:0] edge_counter = 30'd0;
   wire[29:0] active_edge ;
	assign active_edge = duty_cycle*30'd5000/30'd100;
  
  always @(posedge clk_50) begin
    if(edge_counter<30'd5000)
	 edge_counter <= edge_counter+30'd1;
	 else edge_counter<=30'd1;
  end

  
assign out = (edge_counter<=active_edge) ? 1'b1:1'b0;


////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////