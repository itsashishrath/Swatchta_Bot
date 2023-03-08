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
module SB_3320_uart(
	input rst_n,
	input clk_50M,	//50 MHz clock
	output tx,		//UART transmit output
	output tx_clk1,
	output [2:0] PS_status,
	output reg done,
	input uart_start,
	input [2:0] action,
	input [7:0]it,
	input [7:0]bn,
	input [7:0]dz,
	output reg [4:0]data_index
);
////////////////////////WRITE YOUR CODE FROM HERE////////////////////

//reg [2:0] action = 3'd1;
//reg [7:0] it = 8'h4D;
//reg [7:0] bn = 8'h32;
//reg [7:0] dz = 8'h41;

//reg done = 1'b0;

wire tx_clk;
reg [13:0]clk_div;
reg [7:0] tx_reg=8'hff;
reg [2:0]track_count=3'd7;
reg tx_temp;
parameter idle=3'd0, start=3'd1,data=3'd2,stop1=3'd3,stop2=3'd4, prepare_data = 3'd5;
reg [2:0]PS=prepare_data,NS=prepare_data;
reg [7:0] data1 [15:0];
assign tx_clk1 = tx_clk;
//assign data1[7]=8'h23;
//assign data1[6]=8'h2D;
//assign data1[5]=data;
//assign data1[4]=8'h2D;
//assign data1[3]=8'h31;
//assign data1[2]=8'h49;
//assign data1[1]=8'h42;
//assign data1[0]=8'h47;
//reg [4:0] data_index=5'd0;
assign PS_status=PS;


 


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
	else if (uart_start)
		PS <= NS;
	
else PS<=prepare_data;
	
end

	
//always @(posedge tx_clk)
//begin
//	if (data_index == 4'd16)
//		done <= 1'b1;
//	else
//		done <= 1'b0;
		
//	end
always @(PS,track_count,tx_reg,data_index) begin
	case(PS)
		prepare_data: begin
		
		done<=1'b0;
			if (action == 3'd0) begin // pick
				data1[15]<=8'h20;
				data1[14]<=8'h20;
				data1[13]<=8'h20;
				data1[12]<=8'h20;
				data1[11]<=8'h23;
				data1[10]<=8'h2D;
				data1[9]<=8'h4B;
				data1[8]<=8'h43;
				data1[7]<=8'h49;
				data1[6]<=8'h50;
				data1[5]<=8'h2D;
				data1[4]<=it;
				data1[3]<=8'h2D;
				data1[2]<=bn;
				data1[1]<=8'h42;
				data1[0]<=8'h47;
				NS<=idle;
			end
			else if (action == 3'd1) begin  //dump
				data1[15]<=8'h20;
				data1[14]<=8'h50;
				data1[13]<=8'h4D;
				data1[12]<=8'h55;
				data1[11]<=8'h44;
				data1[10]<=8'h2D;
				data1[9]<=dz;
				data1[8]<=8'h5A;	//z
				data1[7]<=8'h44;	//d
				data1[6]<=8'h47;	//g
				data1[5]<=8'h2D;	//-
				data1[4]<=it;		//identification
				data1[3]<=8'h2D;	//-
				data1[2]<=bn;		//block number
				data1[1]<=8'h42;	//b
				data1[0]<=8'h47;  //g
				NS<=idle;
			end
			else if (action == 3'd2) begin    // color
				data1[15]<=8'h20;
				data1[14]<=8'h20;
				data1[13]<=8'h20;
				data1[12]<=8'h20;
				data1[11]<=8'h20;
				data1[10]<=8'h20;
				data1[9]<=8'h20;
				data1[8]<=8'h20;
				data1[7]<=8'h23;
				data1[6]<=8'h2D;
				data1[5]<=it;
				data1[4]<=8'h2D;
				data1[3]<=bn;
				data1[2]<=8'h49;
				data1[1]<=8'h42;
				data1[0]<=8'h47;
				NS<=idle;
			end
			
			else begin
			done<=1'b0;
			NS <= idle;
			end
			
		end
		idle: begin
				done<=1'b0;
				NS <= start;
				tx_temp <= 1'b1;
				
		end	
		start:
			begin
				done<=1'b0;
				NS <= data;
				tx_temp <= 1'b0;
			end	
		data:
			begin
				done<=1'b0;
				if (track_count ==0)
					NS <= stop1;
				else
					NS <= data;
					tx_temp <= tx_reg[0];	
			end	
		stop1:
			begin
				done<=1'b0;
				NS <= stop2;
				tx_temp <= 1'b1;
			end	
		default:
				begin
				
				if (data_index < 16)
						NS <= start;
				else begin
						NS <= prepare_data;
						done <= (uart_start) ? 1'b1 : 1'b0;
				end
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
	if (PS == idle || PS == prepare_data)
		data_index <= 5'd0;
	else
		if (PS == stop1)
			data_index <= data_index + 5'd1;
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