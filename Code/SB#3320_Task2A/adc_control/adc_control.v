// SB : Task 2 A : ADC
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design ADC Controller.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//ADC Controller design
//Inputs  : clk_50 : 50 MHz clock, dout : digital output from ADC128S022 (serial 12-bit)
//Output  : adc_cs_n : Chip Select, din : Ch. address input to ADC128S022, adc_sck : 2.5 MHz ADC clock,
//				d_out_ch5, d_out_ch6, d_out_ch7 : 12-bit output of ch. 5,6 & 7,
//				data_frame : To represent 16-cycle frame (optional)

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////
module adc_control(
	input  clk_50,				//50 MHz clock
	input  dout,				//digital output from ADC128S022 (serial 12-bit)
	output adc_cs_n,			//ADC128S022 Chip Select
	output din,					//Ch. address input to ADC128S022 (serial)
	output adc_sck,			//2.5 MHz ADC clock
	output [11:0]d_out_ch5,	//12-bit output of ch. 5 (parallel)
	output [11:0]d_out_ch6,	//12-bit output of ch. 6 (parallel)
	output [11:0]d_out_ch7,	//12-bit output of ch. 7 (parallel)
	output [1:0]data_frame	//To represent 16-cycle frame (optional)
);
	
////////////////////////WRITE YOUR CODE FROM HERE////////////////////
reg [8:0] counter = 0;
reg [4:0] sck_counter=0;
reg [1:0] dataframe=0;
reg [2:0] din_store=3'b100;
reg dinx;
reg [11:0]data_store;
reg [11:0]ch5=0;
reg [11:0]ch6=0;
reg [11:0]ch7=0;

always@(negedge clk_50) begin      //clock counter to convert into 2.5MHz
	if (counter < 20)
		counter = counter +1;
		else counter = 1;	 
end

assign adc_sck=(counter<11)?0:1;

always@(negedge adc_sck)begin    //Sclk counter to maintain a data frame of 16-bits
if(sck_counter<16)
sck_counter=sck_counter+1;
else sck_counter=1;

if(sck_counter==1) begin        //Data Frame updater
dataframe=dataframe+1;
din_store=din_store+1;           //din updater at beginning of data frame
end

end

assign data_frame=dataframe;
assign adc_cs_n=(sck_counter>=0 && sck_counter<=16)?0:1;          //Adc_cs_n Controller

always@(negedge adc_sck)begin         //din updater at counter 3,4,5 
case(sck_counter)

3:dinx=din_store[2];
4:dinx=din_store[1];
5:dinx=din_store[0];
default:dinx=0;
endcase
end

assign din=dinx;

always@(negedge adc_sck)begin         // store DATA to send 
case(sck_counter)
6:  data_store[11]=dout;
7:  data_store[10]=dout;
8:  data_store[9]=dout;
9:  data_store[8]=dout;
10: data_store[7]=dout;
11: data_store[6]=dout;
12: data_store[5]=dout;
13: data_store[4]=dout;
14: data_store[3]=dout;
15: data_store[2]=dout;
16: data_store[1]=dout;
1:  data_store[0]=dout;
endcase
end

always@(negedge adc_sck)begin										//Stored data assignment at respective data frame
case(dataframe)
2: if(sck_counter==1) begin ch7=data_store; end
3: if(sck_counter==1) begin ch5=data_store; end
0: if(sck_counter==1) begin ch6=data_store; end

endcase
end

assign d_out_ch5=ch5;
assign d_out_ch6=ch6;
assign d_out_ch7=ch7;

////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////