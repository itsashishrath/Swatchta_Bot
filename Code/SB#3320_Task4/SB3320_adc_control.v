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
//Inputs  : .clk_50(clk_50)_50 : 50 MHz clock, dout : digital output from ADC128S022 (serial 12-bit)
//Output  : adc_cs_n : Chip Select, din : Ch. address input to ADC128S022, adc_sck : 2.5 MHz ADC clock,
//				d_out_ch5, d_out_ch6, d_out_ch7 : 12-bit output of ch. 5,6 & 7,
//				data_frame : To represent 16-cycle frame (optional)

//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////
module SB3320_adc_control(
	input reset,
	input  clk_50,				//50 MHz clock
	input  dout,				//digital output from ADC128S022 (serial 12-bit)
	output adc_cs_n,			//ADC128S022 Chip Select
	output din,					//Ch. address input to ADC128S022 (serial)
	output adc_sck,			//2.5 MHz ADC clock
	output [11:0]d_out_ch5,	//12-bit output of ch. 5 (parallel)
	output [11:0]d_out_ch6,	//12-bit output of ch. 6 (parallel)
	output [11:0]d_out_ch7,	//12-bit output of ch. 7 (parallel)
	output [1:0]data_frame,	//To represent 16-cycle frame (optional)
	output sensor_l,
	output sensor_m,
	output sensor_r
);
	
////////////////////////WRITE YOUR CODE FROM HERE////////////////////
parameter s0=3'd0, s1=3'd1,s2=3'd2, s3=3'd3, s4=3'd4, s5=3'd5;
reg[3:0] count = 0;
reg [2:0] present_state = s0;
reg [2:0] next_state;
reg [4:0] clk_div;
reg [1:0]accept_discard = 0;
reg [15:0]d_out_chx=16'd0;
reg [15:0]din_reg;
reg [2:0] channel_sel=0;
wire [2:0] channel_val;
reg [11:0] d_out_ch7_reg=12'd0;
reg [11:0] d_out_ch6_reg=12'd0;
reg [11:0] d_out_ch5_reg=12'd0;
reg [10:0]threshold = 11'd1000;

// Clock Generation
always@(negedge clk_50)
      begin
		  if(clk_div < 5'd19)
			clk_div = clk_div +5'd1;
		  else
			clk_div = 5'd0;
		end
assign din = din_reg[15];		
assign adc_sck = clk_div < 5'd10 ? 1'b0:1'b1;
assign adc_cs_n = 0;

always @( posedge adc_sck)
begin
	if (count == 4'd15)
		if (accept_discard == 2'd3)
			accept_discard <= 2'd1;
		else
			accept_discard <= accept_discard + 2'd1;
	else
		accept_discard <= accept_discard;
end

always @( posedge adc_sck)
begin
	if (count == 4'd15)
		if (channel_sel == 2'd2)
			channel_sel <= 2'd0;
		else
			channel_sel <= channel_sel + 2'd1;
	else
		channel_sel <= channel_sel;
end

assign channel_val = (channel_sel == 2'd0)? 3'd5:
							(channel_sel == 2'd1)? 3'd6: 3'd7;
always @(negedge adc_sck)
begin
	if(count == 4'd0)
			din_reg <={1'd0,channel_val,12'd0};
	else
		din_reg <= {din_reg[14:0],1'd0};
end

		
// tracking_state
always @(negedge adc_sck)
begin
		count <= count + 4'd1;
end

always @(negedge adc_sck)
	begin
		d_out_chx <= {d_out_chx[14:0],dout};
	end
	
	
assign d_out_ch5 = d_out_ch5_reg;
assign d_out_ch6 = d_out_ch6_reg;
assign d_out_ch7 = d_out_ch7_reg;

always @(posedge adc_sck)
begin
	if (count == 4'd0 && accept_discard == 2'd2)
		d_out_ch5_reg <= d_out_chx[11:0];
	else
		d_out_ch5_reg <= d_out_ch5_reg;
end

always @(posedge adc_sck)
begin
	if (count == 4'd0 && accept_discard == 2'd3)
		d_out_ch6_reg <= d_out_chx[11:0];
	else
		d_out_ch6_reg <= d_out_ch6_reg;
end


always @(posedge adc_sck)
begin
	if (count == 4'd0 && accept_discard == 2'd1)
		d_out_ch7_reg <= d_out_chx[11:0];
	else
		d_out_ch7_reg <= d_out_ch7_reg;
end

assign sensor_l = (d_out_ch5<threshold)?1'b0:1'b1;
assign sensor_m = (d_out_ch6<threshold)?1'b0:1'b1;
assign sensor_r = (d_out_ch7<threshold)?1'b0:1'b1;


////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////
