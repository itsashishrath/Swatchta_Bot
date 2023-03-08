module SB3320_motor_control (
	 input clk_50,
    input [2:0]turn,
    output left_motor,
    output right_motor
    
);

reg [2:0]turn_out;
reg [2:0]stop		  =3'b000;
reg [2:0]forward    =3'b001;
reg [2:0]left		  =3'b010;
reg [2:0]right		  =3'b011;
reg [2:0]extreme    =3'b100;


wire [7:0]duty_l;
wire [7:0]duty_r;

reg [7:0]duty_lt;
reg [7:0]duty_rt;


always @(posedge clk_50) begin
    case(turn)

        forward 	 :		begin
								duty_lt=8'd20;
								duty_rt=8'd20;
        end

        left       :    begin
								duty_lt=8'd0;
								duty_rt=8'd20;
        end

        right      :    begin
								duty_lt=8'd20;
								duty_rt=8'd0;
        end

        extreme    : 	begin
								duty_lt=8'd0;
								duty_rt=8'd0;
								//right ground ko high krna padega
		  end

		  stop       :    begin
								duty_lt=8'd0;
								duty_rt=8'd0;
        end
		  
		  
		  default  	 :		begin
								duty_lt=8'd0;
								duty_rt=8'd0;
		  end
		  
    endcase
	 
end

assign duty_l=duty_lt;
assign duty_r=duty_rt;

SB3320_PWM_Generator PWM_Generator_left( .clk_50(clk_50), .duty_cycle(duty_l),  .out(left_motor) );
SB3320_PWM_Generator PWM_Generator_right(.clk_50(clk_50), .duty_cycle(duty_r),  .out(right_motor) );

endmodule 