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
	input rst_n,
	input clk_50M,	//50 MHz clock
	input [7:0] in_data,
	output tx		//UART transmit output
);
////////////////////////WRITE YOUR CODE FROM HERE////////////////////


wire tx_clk;
reg [13:0]clk_div;
reg [7:0] tx_reg=8'hff;
reg [2:0]track_count=3'd7;
reg tx_temp;
parameter idle=3'd0, start=3'd1,data=3'd2,stop1=3'd3,stop2=3'd4, prepare_data = 3'd5;
reg [2:0]PS=prepare_data,NS=prepare_data;
reg [7:0] data1 [7:0];

//assign data1[7]=8'h23;
//assign data1[6]=8'h2D;
//assign data1[5]=8'h4D;
//assign data1[4]=8'h2D;
//assign data1[3]=8'h31;
//assign data1[2]=8'h49;
//assign data1[1]=8'h42;
//assign data1[0]=8'h47;
integer data_index=8;



 
// Clk Generation
//always@(posedge clk_50M,negedge rst_n)
//     begin
//			if (!rst_n)
//				clk_div <= 14'd0;
//			else	
//				
//				if (clk_div < 14'd868)
//					clk_div = clk_div + 14'd1;
//				else
//					 clk_div = 14'd0;
//     end
//
//assign tx_clk = (clk_div < 14'd434)? 1'b0:1'b1;


// 38400
//always@(posedge clk_50M,negedge rst_n)
//     begin
//			if (!rst_n)
//				clk_div <= 14'd0;
//			else	
//				
//				if (clk_div < 14'd2604)
//					clk_div = clk_div + 14'd1;
//				else
//					 clk_div = 14'd0;
//     end
//
//assign tx_clk = (clk_div < 14'd1302)? 1'b0:1'b1;

always@(posedge clk_50M,negedge rst_n)
     begin
			if (!rst_n)
				clk_div <= 14'd0;
			else	
				
				if (clk_div < 14'd2604)
					clk_div = clk_div + 14'd1;
				else
					 clk_div = 14'd0;
     end

assign tx_clk = (clk_div < 14'd1302)? 1'b0:1'b1;

always @(negedge tx_clk,negedge rst_n)
begin
	if (!rst_n)
		PS <= prepare_data;
	else
		PS <= NS;
end	

always @(PS,track_count,tx_reg,data_index) begin
	case(PS)
		prepare_data: begin
			data1[7]=8'h23;
			data1[6]=8'h2D;
			data1[5]=in_data;
			data1[4]=8'h2D;
			data1[3]=8'h31;
			data1[2]=8'h49;
			data1[1]=8'h42;
			data1[0]=8'h47;
			NS <= idle;
		end
		idle: begin
				NS <= start;
				tx_temp <= 1'b1;
		end	
		start:
			begin
				NS <= data;
				tx_temp <= 1'b0;
			end	
		data:
			begin
				if (track_count ==0)
					NS <= stop1;
				else
					NS <= data;
					tx_temp <= tx_reg[0];	
			end	
		stop1:
			begin
				NS <= stop2;
				tx_temp <= 1'b1;
			end	
		default:
				begin
				if (data_index < 8)
						NS <= start;
				else
						NS <= stop2;
				tx_temp <= 1'b1;
				end	
	endcase
end

assign tx = tx_temp;

always @(negedge tx_clk)	
begin
	if (PS == start)
		tx_reg <= data1[data_index];
	else
		if (PS == data)
			tx_reg <= {1'b1,tx_reg[7:1]};
		else
			tx_reg <= tx_reg;
end
			
always @(negedge tx_clk)	
begin
	if (PS == idle)
		data_index <= 0;
	else
		if (PS == stop1)
			data_index <= data_index + 1;
		else
			data_index <= data_index;
end

always @(negedge tx_clk)	
begin
	if (PS == idle)
		track_count <= 3'd7;
	else
		if (PS == data)
			track_count <= track_count - 3'd1;
		else if (PS == stop1)
			track_count <= 3'd7;
end


////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule




///////////////////////////////MODULE ENDS///////////////////////////