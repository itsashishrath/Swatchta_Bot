module SB_3320_line_run(
	 input clk_50,
    input sensor_1,
    input sensor_2,
    input sensor_3,
    output [2:0]turn,
	 output [2:0]turnx
);

reg [2:0]turn_out;
reg [2:0]stop		=3'b000;
reg [2:0]forward  =3'b001;
reg [2:0]left		=3'b010;
reg [2:0]right		=3'b011;
reg [2:0]path_out =3'b100;

always@(posedge clk_50)begin

    if(sensor_1 && sensor_2 && sensor_3)
			  turn_out= stop;
	 
    else if(!sensor_1 && sensor_2 && !sensor_3)
			  turn_out= forward;

    else if(sensor_1 && sensor_2 && !sensor_3)
			  turn_out= left;
	
	 else if(sensor_1 && !sensor_2 && !sensor_3)
			  turn_out= left;

    else if(!sensor_1 && sensor_2 && sensor_3)
			  turn_out=right;
			  
	 else if(!sensor_1 && !sensor_2 && sensor_3)
			  turn_out=right;
			  
	 else turn_out=path_out;
			  

end

assign turn=turn_out;
assign turnx=left;

endmodule