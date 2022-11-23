// SB : Task 2 B : UART
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design UART Transmitter.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//UART Transmitter design
//Input   : clk_50M : 50 MHz clock
//Output  : tx : UART transmit output

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////
module uart(
	input clk_50M,	//50 MHz clock
	output tx		//UART transmit output
);
////////////////////////WRITE YOUR CODE FROM HERE////////////////////

parameter s0 = 4'd0,      //Assing all the State to some default values.
			 s1 = 4'd1,
			 s2 = 4'd2,
			 s3 = 4'd3,
			 s4 = 4'd4;


reg [0:8] counter;      		//Creating counter for creating baudRate clock
wire clk_2;							//Creating a clk_2 according to baudRate provided.
reg [0:7] tx_data [0:3];		//To store all data in array which we have to transmite.
reg [0:3] state = s0;			//As we are using fsm approch for this problem we have use state.
reg tx_temp;						//To store all output data temp for later assiging.
reg [0:3]data_frame = 0;		//To keep track of how much data has been transmitted.
reg [0:3]counter_2 = 0;		//To keep track of how much bits are trasmitted.


// define paramaters for UART transmitter
parameter 
duration_of_bits = 8680,
clocks_per_bit = duration_of_bits/20;


always @ (posedge clk_50M) begin  //Creating a new clk in accordance to baudRate provided.
	if (counter < clocks_per_bit)
		counter = counter + 9'd1;
	else
		counter = 9'd1;
end


assign clk_2 = (counter < 218)?1'b0:1'b1;		//Assiging new clk


always @ (negedge clk_2) begin
	
	//Storing all data in 8 bit binary form.
	tx_data[0] = 8'b11001010;//S
	tx_data[1] = 8'b01000010;//B
	tx_data[2] = 8'b01001100;//2
	tx_data[3] = 8'b00001100;//0
	
	
	case(state) 		//Using case to assing all the output in accordance with the task

	s0: begin       			//s0 assing Ideal State which is 1.
			tx_temp = 1'b1;
			state <= s1;
		 end
		
	s1: begin					//S1 assing Starting bit which is 0.
			tx_temp = 1'b0;
			state <= s2;
		 end
		
	s2: begin 															//S2 assing our important data which we have to transmit 
			if(counter_2 <= 7) begin
				tx_temp = tx_data[data_frame][counter_2];		//Here we are assiging the 8 bit to the output.
				counter_2 <= counter_2 + 4'd1;
				if(counter_2 == 7) state <= s3;
			end
			
		 end
		
	s3: begin											//s3 assign stop bit 1.
			data_frame <= data_frame + 4'd1;
			counter_2 <= 4'd0;
			tx_temp = 1'b1;
			state <= s4;
		 end
		
	s4: begin 											//s4 assign stop bit 2 and our code remaing at this state after all data is transfered.
			if (data_frame > 3) begin
				tx_temp = 1'b1;
			end
			else begin
				tx_temp = 1'b1;
				state <= s1;
			end
		 end
		
	endcase
	

end


assign tx = tx_temp;					//Assiging our temp output to the main output.

////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////