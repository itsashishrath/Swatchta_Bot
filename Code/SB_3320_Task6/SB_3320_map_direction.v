module SB_3320_map_direction(
	input start,
	input clk_50,
	input [4:0]previous_node,
	input [4:0]current_node,
	input [4:0]next_node,
	output [2:0] direction
);

parameter s1=3'd0,
				 	s2=3'd1;
	
reg [2:0]stop		=3'b000;
reg [2:0]forward  =3'b001;
reg [2:0]left		=3'b010;
reg [2:0]right		=3'b011;
reg [2:0]	extreme = 3'b100;

reg [2:0] state = s1;

reg [2:0] map [27:0][27:0][27:0];
reg [2:0] direction_temp;	




always@(posedge clk_50) begin
	if(start) begin
		case(state) 
			s1:		begin 
				map[27][0][1] = forward;																																map[1][0][27] =extreme;

				map[0][1][13] = forward;				map[0][1][2] = right;				map[2][1][0] = left;
				map[13][1][0] = forward;				map[2][1][13] = right;			map[13][1][2] = left;

				map[1][2][5] = forward;					map[3][2][1] = right; 			map[1][2][3] = left;
				map[5][2][1] = forward;					map[5][2][3] = right;				map[3][2][5] = left;

				map[27][3][2]	= forward;																																map[2][3][27] = extreme;

				map[27][4][6] = forward;																																map[6][4][27] = extreme; 

				map[2][5][6] = forward;					map[9][5][2] = right;				map[2][5][9] 	=left;
				map[6][5][2] = forward;					map[6][5][9] = right;				map[9][5][6] 	=left;

				map[5][6][16]	 = forward;				map[5][6][4] = right; 			map[4][6][5] = left;
				map[16][6][5]	= forward;				map[4][6][16] = right;			map[16][6][4] = left;

				map[27][7][12] = forward;																																map[12][7][27] = extreme; 
				map[27][8][9] = forward;																																map[9][8][27]   = extreme;

				map[15][9][5] = forward;				map[8][9][5] = right; 			map[5][9][8] = left;
				map[5][9][15]	= forward;				map[15][9][8] = right;			map[8][9][15] = left;

				map[27][10][16] = forward;																															map[16][10][27] = extreme;

				map[27][11][12] = forward;																															map[12][11][27] = extreme;

				map[13][12][11] = forward;			map[13][12][17] = right;		map[17][12][13] = left; 	
				map[11][12][13] = forward;			map[7][12][13]  = right; 		map[13][12][7]  = left;
															map[17][12][11] = right;		map[11][12][17] =left;

				map[17][12][7] = forward;
				map[7][12][17] = forward;

				map[1][13][18] = forward;			map[12][13][1]  = right; 		map[1][13][12] = left;	 	
				map[18][13][1] = forward;			map[18][13][12] = right;		map[12][13][18] = left;

				map[27][14][15] = forward;																															map[15][14][27] = extreme; 

				map[9][15][22] = forward;			map[22][15][14] = right; 		map[14][15][22] = left;
				map[22][15][9] = forward;			map[14][15][9]  = right;		map[9][15][14] = left;

				map[23][16][6] = forward;			map[23][16][10] = right; 		map[10][16][23] = left;
				map[6][16][23] = forward;			map[10][16][6] = right;			map[6][16][10] = left;

				map[27][17][12]=forward;																																map[12][17][27] = extreme;

				map[13][18][19] = forward;		map[20][18][19] = right;		map[19][18][20] = left;
				map[19][18][13] = forward;		map[13][18][20] = right; 		map[20][18][13] = left;

				map[27][19][18] = forward;																															map[18][19][27] = extreme;

				map[18][20][22] = forward;		map[21][20][18] = right;		map[18][20][21] = left; 	
				map[22][20][18] = forward;		map[22][20][21] = right;		map[21][20][20] = left;

				map[27][21][20] = forward;																																map[20][21][27] = extreme; 

				map[20][22][23] = forward; 	map[20][22][15] = right;			map[15][22][20] = left; 
				map[23][22][20] = forward;		map[15][22][23] = right;			map[23][22][15] = left;
				map[15][22][25] = forward;		map[23][22][25] = right;			map[25][22][23] = left;
														map[25][22][20] =right;				map[20][22][25] =left;

				map[25][22][15] = forward;

				map[22][23][16] = forward;  	map[24][23][22] = right;			map[22][23][24] = left; 	
				map[16][23][22] = forward;		map[16][23][24] = right;			map[24][23][16] = left;

				map[27][24][23] = forward;																																map[23][24][27] = extreme; 
				map[27][25][22] = forward;																																map[22][25][27] = extreme; 
				state=s2;
			end
		
			s2: begin
				direction_temp = map[previous_node][current_node][next_node];
			end
			
		endcase
	end
end

assign direction = direction_temp; 

endmodule