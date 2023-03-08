module SB_3320_bot_turn_control (
	 input clk_50,
    input [2:0]turn,
    output left_motor,
    output right_motor,
	 output gndl,
	 output gndr
    
);

reg [2:0]turn_out;
reg [2:0]stop		  =3'b000;
reg [2:0]forward    =3'b001;
reg [2:0]left		  =3'b010;
reg [2:0]right		  =3'b011;
reg [2:0]extreme    =3'b100;


wire [7:0]duty_l;
wire [7:0]duty_r;
wire [7:0]duty_gl;
wire [7:0]duty_gr;

reg [7:0]duty_lt;
reg [7:0]duty_rt;
reg [7:0]duty_glt;
reg [7:0]duty_grt;


always @(posedge clk_50) begin
    case(turn)

        forward 	 :		begin
								duty_lt=8'd83;
								duty_rt=8'd83;
								duty_glt=8'd0;
								duty_grt=8'd0;
								
								
        end

        left       :    begin
								duty_lt =8'd0;
								duty_rt =8'd0;
								duty_glt=8'd0;
								duty_grt=8'd82;
        end

        right      :    begin
								duty_lt =8'd0;
								duty_rt =8'd0;
								duty_glt=8'd82;
								duty_grt=8'd0;
        end

        extreme    : 	begin
								duty_lt =8'd0;
								duty_rt =8'd0;
								duty_glt=8'd81;
								duty_grt=8'd0;
		  end

		  stop       :    begin
								duty_lt=8'd0;
								duty_rt=8'd0;
								duty_glt=8'd0;
								duty_grt=8'd0;
        end
		  
		  
		  default  	 :		begin
								duty_lt=8'd0;
								duty_rt=8'd0;
								duty_glt=8'd0;
								duty_grt=8'd0;
		  end
		  
    endcase
	 
end

assign duty_l=duty_lt;
assign duty_r=duty_rt;
assign duty_gl=duty_glt;
assign duty_gr=duty_grt;

SB_3320_PWM_Generator PWM_Generator_left    ( .clk_50(clk_50), .duty_cycle(duty_l),  .out(left_motor) );
SB_3320_PWM_Generator PWM_Generator_right   ( .clk_50(clk_50), .duty_cycle(duty_r),  .out(right_motor));
SB_3320_PWM_Generator PWM_Generator_gndleft ( .clk_50(clk_50), .duty_cycle(duty_gl), .out(gndl)       );
SB_3320_PWM_Generator PWM_Generator_gndright( .clk_50(clk_50), .duty_cycle(duty_gr), .out(gndr)       );



endmodule 