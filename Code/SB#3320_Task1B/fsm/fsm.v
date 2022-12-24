// SB : Task 1 B : Finite State Machine
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a Finite State Machine.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
			Do not make any changes to Test_Bench_Vector.txt file. Violating will result into Disqualification.
-------------------
*/

//Finite State Machine design
//Inputs  : I (4 bit) and CLK (clock)
//Output  : Y (Y = 1 when 102210 sequence(decimal number sequence) is detected)

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////
module fsm(
	input CLK,			  //Clock
	input [3:0]I,       //INPUT I
	output	  Y		  //OUTPUT Y
);

reg Y1 = 0;
assign Y = Y1;


////////////////////////WRITE YOUR CODE FROM HERE//////////////////// 
// define 6 states as we need to identify 102210
parameter s0 = 4'd0,
			 s1 = 4'd1,
			 s2 = 4'd2,
			 s3 = 4'd3,
			 s4 = 4'd4,
			 s5 = 4'd5;

// inititate state
reg [3:0] state = s0, next_state;

always @ (posedge CLK) begin
	state <= next_state;
end

always @ (state, I) begin
	// apply switch case on current state
	case (state)
		s0: begin
			if (I == 4'd1) next_state = s1;
			else next_state = s0;
		end
		s1: begin
			if (I == 4'd0) next_state = s2;
			else
				if (I == 4'd1) next_state = s1;
				else next_state = s0;
		end
		s2: begin
			if (I == 4'd2) next_state = s3;
			else
				if (I == 4'd1) next_state = s1;
				else next_state = s0;
		end
		s3: begin
			if (I == 4'd2) next_state = s4;
			else
				if (I == 4'd1) next_state = s1;
				else next_state = s0;
		end
		s4: begin
			if (I == 4'd1) next_state = s5;
			else
				next_state = s0;
		end
		s5: begin
			if (I == 4'd0) next_state = s2;
			else
				if (I == 4'd1) next_state = s1;
				else next_state = s0;
		end
	endcase
end

always @ (posedge CLK) begin
	// assign value to output
	Y1 <= (state == s5 && I == 4'd0) ? 1'b1 : 1'b0;
end

// Tip : Write your code such that Quartus Generates a State Machine 
//			(Tools > Netlist Viewers > State Machine Viewer).
// 		For doing so, you will have to properly declare State Variables of the
//       State Machine and also perform State Assignments correctly.
//			Use Verilog case statement to design.
	
	

////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////