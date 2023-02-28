module SB_3320_color_sensor(rst_n,clk50,S0,S1,S2,S3,OUT,red,green, blue,clk_0_1,clk_new, red_led, blue_led, green_led, message,start, done);
	input start;
	input clk50,OUT,rst_n;
	output reg S0,S2,S3;
	output S1, red_led, blue_led, green_led;
	output reg [9:0] red, green, blue;
	output [7:0] message;
	output done;

	
	reg [9:0]red_final;
	reg [9:0]green_final;
	reg [9:0]blue_final;
	
	reg [7:0] message_temp;
	reg [1:0]done_temp;
	reg [3:0] PS, NS;
	reg [22:0] clk_div;
	parameter idle=4'd0 , enable_red=4'd1,disp_red=4'd2,count_zero_1=4'd3,enable_green=4'd4,disp_green=4'd5,count_zero_2=4'd6,enable_blue=4'd7, disp_blue=4'd8, count_zero_3=4'd9;
	reg [9:0] pulse_counter;
	reg red_led_value=1'b0;
	reg blue_led_value=1'b0;
	reg green_led_value=1'b0;
	output clk_0_1;
	output clk_new;
	reg [9:0]clk_divider;
	
	always @(posedge clk50, negedge rst_n)
	
	begin	
	
		if (!rst_n)
			clk_divider = 10'd0;
		else
			clk_divider <= clk_divider + 10'd1;
			
		end
	assign clk_new = clk_divider[9];
	
	always @(posedge clk_new, negedge rst_n)
	
	begin	
	 
		if (!rst_n)
			clk_div = 13'd0;
		else
			if (clk_div < 13'd5000)
				clk_div <= clk_div + 13'd1;
			else
				clk_div <= 13'd0;
		end
	assign clk_0_1 = (clk_div < 13'd2500)? 1'b0:1'b1;

		always @(posedge clk_0_1,negedge rst_n)
		
		begin
			
			if(!rst_n)
				PS <= idle;
			else	
				PS <=NS;
		end

		always @(PS)
		 
			begin
				
				 case (PS) 
			idle : 
				NS <= enable_red;
			enable_red: 
				NS <= disp_red;
			disp_red:
				NS <= count_zero_1;
			count_zero_1 :	
				NS <= enable_blue;
			enable_blue:
				NS <= disp_blue;
			disp_blue:
				NS <= count_zero_2;
			count_zero_2 :	
				NS <= enable_green;
			enable_green:
				NS <= disp_green;
			disp_green:
				NS <= count_zero_3;
			default :	
				NS <= enable_red;
			endcase	
		end
		
	//	assign S0 = 1'b1;
		assign S1 = 1'b0;
				
		always @(posedge clk50, negedge rst_n)
		
		begin
		 
			if (!rst_n)
			begin
				S2 <= 1'b0;
				S3 <= 1'b0;
		
			end
			else
				if (PS == enable_red)
				begin
					S2 <= 1'b0;
					S3 <= 1'b0;
				end
				else
					if (PS == enable_blue)
						begin
							S2 <= 1'b0;
							S3 <= 1'b1;
							
						end
					else
					if (PS == enable_green)
						begin
							S2 <= 1'b1;
							S3 <= 1'b1;
						end

						else
							begin	
								S2 <= S2;
								S3 <= S3;
						end
	
		end
		
		always @ (posedge clk50, negedge rst_n)
		
		begin
		 
			if (!rst_n)
			 S0 <= 1'b0;
			else
				if(PS == enable_red || PS == enable_blue || PS == enable_green)
					S0 <= 1'b1;
				else
					S0 <= 1'b0;
		
		end
		
		
		
			wire pulse_clear;	
			assign pulse_clear = (PS==count_zero_1 || PS== count_zero_2 || PS ==count_zero_3)? 1'b0:1'b1;
				always @(posedge OUT, negedge pulse_clear)
				
				begin
				 
					if (!pulse_clear)
						pulse_counter <= 10'd0;
					else
						if(PS==enable_red || PS== enable_blue || PS ==enable_green)
					   pulse_counter <= pulse_counter + 10'd1;
				end
				
			always @(posedge clk50,negedge rst_n)
			
				begin
				 
					if (!rst_n)
						red <= 10'd0;
					else
						if(PS == disp_red)
							red <= pulse_counter;
						else
							red <= red;
				end
				
			always @(posedge clk50,negedge rst_n)
			  
				begin
				 
					if (!rst_n)
						green <= 10'd0;
					else
						if(PS == disp_green) begin
							green <= pulse_counter;
						end
						else
							green <= green;
						
						
				end
				
				always @(posedge clk50,negedge rst_n)
				begin
				 
					if (!rst_n)
						blue <= 10'd0;
					else
						if(PS == disp_blue)
							blue <= pulse_counter;
						else
							blue <= blue;
				end
				

always@(posedge clk50)

if(start)
begin
 
if(red>80) red_final=red;
if(green>80)green_final=green;
if(blue>80)blue_final=blue;

if(red_final>150 && red_final<250 && green_final>180 && green_final<270 
		&& blue_final>110 && blue_final<190) 
		begin
		green_led_value=1'b1;
		red_led_value=1'b0;
		blue_led_value=1'b0;
		message_temp = 8'h44;
		done_temp=1'b1;
		end
		
		else if(red_final>280 && red_final<390 && green_final>70 && green_final<170 
		&& blue_final>90 && blue_final<190) begin 
		red_led_value=1'b1;
		green_led_value=1'b0;
		blue_led_value=1'b0;
		message_temp = 8'h4D;
		done_temp=1'b1;
		end
		
		else if(red_final>70 && red_final<170 && green_final>80 && green_final<190
		&& blue_final>170 && blue_final<280)
		begin
		blue_led_value=1'b1;
		red_led_value=1'b0;
		green_led_value=1'b0;
		message_temp = 8'h57;
		done_temp=1'b1;
		end 	
		
		
		else
				begin
				blue_led_value=1'b0;
				red_led_value=1'b0;
				green_led_value=1'b0;
				done_temp=1'b0;
			   end
		
		 	
end			
				assign red_led   = red_led_value;
				assign blue_led  = blue_led_value;
				assign green_led = green_led_value;
				
				assign done =(start)?done_temp:1'b0;
				assign message = message_temp;
				
endmodule
