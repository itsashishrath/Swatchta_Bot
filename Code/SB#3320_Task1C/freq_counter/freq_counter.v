// SB : Task 1C Frequency Counter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design 2:1 Multiplexer.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
			Do not make any changes to Test_Bench_Vector.txt file. Violating will result into Disqualification.
-------------------
*/

//Freq Counter design
//Inputs	: clk & ip_sig (input signal)
//Output	: count (8 bits)

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////
module freq_counter(
	input clk,
	input ip_sig,
	output s0,
	output s1,
	output s2,
	output s3,
	output red,
	output reg [7:0] count = 0
);


////////////////////////WRITE YOUR CODE FROM HERE//////////////////// 


reg [7:0] count_temp = 0;   // Defined a Variable for temporary count
reg s0_data = 1;
reg s1_data = 0;
reg s2_data = 0;
reg s3_data = 0;
reg red_confirm = 0;
always @ (posedge clk)
begin
if(ip_sig)
 count_temp <= count_temp + 1;   // If ip_sig is positive for each positive clk then count_temp will increase by 1 each time.
 else
 count_temp <= 0;						// Count_temp value will reset when ip_sign is low
 end
 
 always @(negedge ip_sig )
 begin
 
 count<=count_temp;
           // count will be declared according to the conditions which is mentioned above and count will take the value of count_temp.
if (count <= 200 && count >= 170) begin
	red_confi
	
	
	
	
	
	
	rm = 1;
end else begin
	red_confirm = 0;
end
 end
 assign s0 = s0_data;
 assign s1 = s1_data;
 assign s2 = s2_data;
 assign s3 = s3_data;
 assign red = red_confirm;
////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE END S///////////////////////////
