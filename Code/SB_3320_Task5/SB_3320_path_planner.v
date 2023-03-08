// SM : Task 2 C : Path Planning
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design path planner.

Recommended Quartus Version : 19.1
The submitted project file must be 19.1 compatible as the evaluation will be done on Quartus Prime Lite 19.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Path Planner design
//Parameters : node_count : for total no. of nodes + 1 (consider an imaginary node, refer discuss forum),
//					max_edges : no. of max edges for every node.


//Inputs  	 : clk : 50 MHz clock, 
//				   start : start signal to initiate the path planning,
//				   s_node : start node,
//				   e_node : destination node.
//
//Output     : done : Path planning completed signal,
//             final_path : the final path from start to end node.



//////////////////DO NOT MAKE ANY CHANGES IN MODULE//////////////////

module SB_3320_path_planner
#(parameter n= 27, parameter max_edges = 4)
(
	input clk_50,
	input start,
	input [4:0] s_node,
	input [4:0] e_node,
	output reg done,	
	output reg [10*5-1:0] final_path
);

////////////////////////WRITE YOUR CODE FROM HERE////////////////////

// initialize parameters necessary for dijsktra algorithm
parameter initialise = 4'd0,
			 path_out = 4'd1,
			 initial_distance = 4'd2,
			 nextnode_finder = 4'd3,
			 path_updater = 4'd4,
			 path_tracing = 4'd5;


reg [7:0] counter =8'd0;
reg [7:0] cost [0:26][0:26]; // initialize total cost for dijsktra
reg [7:0] distance[0:26]; // distance between previous node from current
reg [7:0] visited[0:26]; // to mark visited node
reg [7:0] pred[0:26]; // to backtrack the path
reg [7:0] infinity=8'd30; // max value for infinity
reg [3:0] state = initialise; //  initialize state for fsm
reg [7:0] mindistance;
reg [7:0] nextnode;
reg [4:0] t;
reg [7:0] count=8'd0;
reg [4:0] temp_path [9:0]; // to store temporary results
reg [3:0] x;



always@(posedge clk_50)begin
 
	case(state)
		 // to initialize path, initialized all the distances to save clock count
		 initialise: begin 	
			cost[0][0]=infinity; cost[0][1]=8'd3; cost[0][2]=infinity; cost[0][3]=infinity; cost[0][4]=infinity; cost[0][5]=infinity; cost[0][6]=infinity; cost[0][7]=infinity; cost[0][8]=infinity; cost[0][9]=infinity; cost[0][10]=infinity; 
			cost[0][11]=infinity; cost[0][12]=infinity; cost[0][13]=infinity; cost[0][14]=infinity; cost[0][15]=infinity; cost[0][16]=infinity; cost[0][17]=infinity; cost[0][18]=infinity; cost[0][19]=infinity; cost[0][20]=infinity; cost[0][21]=infinity; cost[0][22]=infinity; cost[0][23]=infinity; cost[0][24]=infinity; cost[0][25]=infinity; cost[0][26]=infinity;
			cost[1][0]=8'd3; cost[1][1]=infinity; cost[1][2]=8'd3; cost[1][3]=infinity; cost[1][4]=infinity; cost[1][5]=infinity; cost[1][6]=infinity; cost[1][7]=infinity; cost[1][8]=infinity; cost[1][9]=infinity; cost[1][10]=infinity; 
			cost[1][11]=infinity; cost[1][12]=infinity; cost[1][13]=8'd3; cost[1][14]=infinity; cost[1][15]=infinity; cost[1][16]=infinity; cost[1][17]=infinity; cost[1][18]=infinity; cost[1][19]=infinity; cost[1][20]=infinity; cost[1][21]=infinity; cost[1][22]=infinity; cost[1][23]=infinity; cost[1][24]=infinity; cost[1][25]=infinity; cost[1][26]=infinity;
			cost[2][0]=infinity; cost[2][1]=8'd3; cost[2][2]=infinity; cost[2][3]=8'd1; cost[2][4]=infinity; cost[2][5]=8'd3; cost[2][6]=infinity; cost[2][7]=infinity; cost[2][8]=infinity; cost[2][9]=infinity; cost[2][10]=infinity; 
			cost[2][11]=infinity; cost[2][12]=infinity; cost[2][13]=infinity; cost[2][14]=infinity; cost[2][15]=infinity; cost[2][16]=infinity; cost[2][17]=infinity; cost[2][18]=infinity; cost[2][19]=infinity; cost[2][20]=infinity; cost[2][21]=infinity; cost[2][22]=infinity; cost[2][23]=infinity; cost[2][24]=infinity; cost[2][25]=infinity; cost[2][26]=infinity;
			cost[3][0]=infinity; cost[3][1]=infinity; cost[3][2]=8'd1; cost[3][3]=infinity; cost[3][4]=infinity; cost[3][5]=infinity; cost[3][6]=infinity; cost[3][7]=infinity; cost[3][8]=infinity; cost[3][9]=infinity; cost[3][10]=infinity; 
			cost[3][11]=infinity; cost[3][12]=infinity; cost[3][13]=infinity; cost[3][14]=infinity; cost[3][15]=infinity; cost[3][16]=infinity; cost[3][17]=infinity; cost[3][18]=infinity; cost[3][19]=infinity; cost[3][20]=infinity; cost[3][21]=infinity; cost[3][22]=infinity; cost[3][23]=infinity; cost[3][24]=infinity; cost[3][25]=infinity; cost[3][26]=infinity;
			cost[4][0]=infinity; cost[4][1]=infinity; cost[4][2]=infinity; cost[4][3]=infinity; cost[4][4]=infinity; cost[4][5]=infinity; cost[4][6]=8'd3; cost[4][7]=infinity; cost[4][8]=infinity; cost[4][9]=infinity; cost[4][10]=infinity; 
			cost[4][11]=infinity; cost[4][12]=infinity; cost[4][13]=infinity; cost[4][14]=infinity; cost[4][15]=infinity; cost[4][16]=infinity; cost[4][17]=infinity; cost[4][18]=infinity; cost[4][19]=infinity; cost[4][20]=infinity; cost[4][21]=infinity; cost[4][22]=infinity; cost[4][23]=infinity; cost[4][24]=infinity; cost[4][25]=infinity; cost[4][26]=infinity;
			cost[5][0]=infinity; cost[5][1]=infinity; cost[5][2]=8'd3; cost[5][3]=infinity; cost[5][4]=infinity; cost[5][5]=infinity; cost[5][6]=8'd1; cost[5][7]=infinity; cost[5][8]=infinity; cost[5][9]=8'd2; cost[5][10]=infinity; 
			cost[5][11]=infinity; cost[5][12]=infinity; cost[5][13]=infinity; cost[5][14]=infinity; cost[5][15]=infinity; cost[5][16]=infinity; cost[5][17]=infinity; cost[5][18]=infinity; cost[5][19]=infinity; cost[5][20]=infinity; cost[5][21]=infinity; cost[5][22]=infinity; cost[5][23]=infinity; cost[5][24]=infinity; cost[5][25]=infinity; cost[5][26]=infinity;
			cost[6][0]=infinity; cost[6][1]=infinity; cost[6][2]=infinity; cost[6][3]=infinity; cost[6][4]=8'd3; cost[6][5]=8'd1; cost[6][6]=infinity; cost[6][7]=infinity; cost[6][8]=infinity; cost[6][9]=infinity; cost[6][10]=infinity; 
			cost[6][11]=infinity; cost[6][12]=infinity; cost[6][13]=infinity; cost[6][14]=infinity; cost[6][15]=infinity; cost[6][16]=8'd3; cost[6][17]=infinity; cost[6][18]=infinity; cost[6][19]=infinity; cost[6][20]=infinity; cost[6][21]=infinity; cost[6][22]=infinity; cost[6][23]=infinity; cost[6][24]=infinity; cost[6][25]=infinity; cost[6][26]=infinity;
			cost[7][0]=infinity; cost[7][1]=infinity; cost[7][2]=infinity; cost[7][3]=infinity; cost[7][4]=infinity; cost[7][5]=infinity; cost[7][6]=infinity; cost[7][7]=infinity; cost[7][8]=infinity; cost[7][9]=infinity; cost[7][10]=infinity; 
			cost[7][11]=infinity; cost[7][12]=8'd2; cost[7][13]=infinity; cost[7][14]=infinity; cost[7][15]=infinity; cost[7][16]=infinity; cost[7][17]=infinity; cost[7][18]=infinity; cost[7][19]=infinity; cost[7][20]=infinity; cost[7][21]=infinity; cost[7][22]=infinity; cost[7][23]=infinity; cost[7][24]=infinity; cost[7][25]=infinity; cost[7][26]=infinity;
			cost[8][0]=infinity; cost[8][1]=infinity; cost[8][2]=infinity; cost[8][3]=infinity; cost[8][4]=infinity; cost[8][5]=infinity; cost[8][6]=infinity; cost[8][7]=infinity; cost[8][8]=infinity; cost[8][9]=8'd1; cost[8][10]=infinity; 
			cost[8][11]=infinity; cost[8][12]=infinity; cost[8][13]=infinity; cost[8][14]=infinity; cost[8][15]=infinity; cost[8][16]=infinity; cost[8][17]=infinity; cost[8][18]=infinity; cost[8][19]=infinity; cost[8][20]=infinity; cost[8][21]=infinity; cost[8][22]=infinity; cost[8][23]=infinity; cost[8][24]=infinity; cost[8][25]=infinity; cost[8][26]=infinity;
			cost[9][0]=infinity; cost[9][1]=infinity; cost[9][2]=infinity; cost[9][3]=infinity; cost[9][4]=infinity; cost[9][5]=8'd2; cost[9][6]=infinity; cost[9][7]=infinity; cost[9][8]=8'd1; cost[9][9]=infinity; cost[9][10]=infinity; 
			cost[9][11]=infinity; cost[9][12]=infinity; cost[9][13]=infinity; cost[9][14]=infinity; cost[9][15]=8'd1; cost[9][16]=infinity; cost[9][17]=infinity; cost[9][18]=infinity; cost[9][19]=infinity; cost[9][20]=infinity; cost[9][21]=infinity; cost[9][22]=infinity; cost[9][23]=infinity; cost[9][24]=infinity; cost[9][25]=infinity; cost[9][26]=infinity;
			cost[10][0]=infinity; cost[10][1]=infinity; cost[10][2]=infinity; cost[10][3]=infinity; cost[10][4]=infinity; cost[10][5]=infinity; cost[10][6]=infinity; cost[10][7]=infinity; cost[10][8]=infinity; cost[10][9]=infinity; cost[10][10]=infinity; cost[10][11]=infinity; cost[10][12]=infinity; cost[10][13]=infinity; cost[10][14]=infinity; cost[10][15]=infinity; cost[10][16]=8'd2; cost[10][17]=infinity; cost[10][18]=infinity; cost[10][19]=infinity; cost[10][20]=infinity; cost[10][21]=infinity; cost[10][22]=infinity; cost[10][23]=infinity; cost[10][24]=infinity; cost[10][25]=infinity; cost[10][26]=infinity; 
			cost[11][0]=infinity; cost[11][1]=infinity; cost[11][2]=infinity; cost[11][3]=infinity; cost[11][4]=infinity; cost[11][5]=infinity; cost[11][6]=infinity; cost[11][7]=infinity; cost[11][8]=infinity; cost[11][9]=infinity; cost[11][10]=infinity; cost[11][11]=infinity; cost[11][12]=8'd3; cost[11][13]=infinity; cost[11][14]=infinity; cost[11][15]=infinity; cost[11][16]=infinity; cost[11][17]=infinity; cost[11][18]=infinity; cost[11][19]=infinity; cost[11][20]=infinity; cost[11][21]=infinity; cost[11][22]=infinity; cost[11][23]=infinity; cost[11][24]=infinity; cost[11][25]=infinity; cost[11][26]=infinity;
			cost[12][0]=infinity; cost[12][1]=infinity; cost[12][2]=infinity; cost[12][3]=infinity; cost[12][4]=infinity; cost[12][5]=infinity; cost[12][6]=infinity; cost[12][7]=8'd2; cost[12][8]=infinity; cost[12][9]=infinity; cost[12][10]=infinity; cost[12][11]=8'd3; cost[12][12]=infinity; cost[12][13]=8'd1; cost[12][14]=infinity; cost[12][15]=infinity; cost[12][16]=infinity; cost[12][17]=8'd3; cost[12][18]=infinity; cost[12][19]=infinity; cost[12][20]=infinity; cost[12][21]=infinity; cost[12][22]=infinity; cost[12][23]=infinity; cost[12][24]=infinity; cost[12][25]=infinity; cost[12][26]=infinity;
			cost[13][0]=infinity; cost[13][1]=8'd3; cost[13][2]=infinity; cost[13][3]=infinity; cost[13][4]=infinity; cost[13][5]=infinity; cost[13][6]=infinity; cost[13][7]=infinity; cost[13][8]=infinity; cost[13][9]=infinity; cost[13][10]=infinity; cost[13][11]=infinity; cost[13][12]=8'd1; cost[13][13]=infinity; cost[13][14]=infinity; cost[13][15]=infinity; cost[13][16]=infinity; cost[13][17]=infinity; cost[13][18]=8'd2; cost[13][19]=infinity; cost[13][20]=infinity; cost[13][21]=infinity; cost[13][22]=infinity; cost[13][23]=infinity; cost[13][24]=infinity; cost[13][25]=infinity; cost[13][26]=infinity;
			cost[14][0]=infinity; cost[14][1]=infinity; cost[14][2]=infinity; cost[14][3]=infinity; cost[14][4]=infinity; cost[14][5]=infinity; cost[14][6]=infinity; cost[14][7]=infinity; cost[14][8]=infinity; cost[14][9]=infinity; cost[14][10]=infinity; cost[14][11]=infinity; cost[14][12]=infinity; cost[14][13]=infinity; cost[14][14]=infinity; cost[14][15]=8'd1; cost[14][16]=infinity; cost[14][17]=infinity; cost[14][18]=infinity; cost[14][19]=infinity; cost[14][20]=infinity; cost[14][21]=infinity; cost[14][22]=infinity; cost[14][23]=infinity; cost[14][24]=infinity; cost[14][25]=infinity; cost[14][26]=infinity;
			cost[15][0]=infinity; cost[15][1]=infinity; cost[15][2]=infinity; cost[15][3]=infinity; cost[15][4]=infinity; cost[15][5]=infinity; cost[15][6]=infinity; cost[15][7]=infinity; cost[15][8]=infinity; cost[15][9]=8'd1; cost[15][10]=infinity; cost[15][11]=infinity; cost[15][12]=infinity; cost[15][13]=infinity; cost[15][14]=8'd1; cost[15][15]=infinity; cost[15][16]=infinity; cost[15][17]=infinity; cost[15][18]=infinity; cost[15][19]=infinity; cost[15][20]=infinity; cost[15][21]=infinity; cost[15][22]=8'd1; cost[15][23]=infinity; cost[15][24]=infinity; cost[15][25]=infinity; cost[15][26]=infinity;
			cost[16][0]=infinity; cost[16][1]=infinity; cost[16][2]=infinity; cost[16][3]=infinity; cost[16][4]=infinity; cost[16][5]=infinity; cost[16][6]=8'd3; cost[16][7]=infinity; cost[16][8]=infinity; cost[16][9]=infinity; cost[16][10]=8'd2; cost[16][11]=infinity; cost[16][12]=infinity; cost[16][13]=infinity; cost[16][14]=infinity; cost[16][15]=infinity; cost[16][16]=infinity; cost[16][17]=infinity; cost[16][18]=infinity; cost[16][19]=infinity; cost[16][20]=infinity; cost[16][21]=infinity; cost[16][22]=infinity; cost[16][23]=8'd2; cost[16][24]=infinity; cost[16][25]=infinity; cost[16][26]=infinity;
			cost[17][0]=infinity; cost[17][1]=infinity; cost[17][2]=infinity; cost[17][3]=infinity; cost[17][4]=infinity; cost[17][5]=infinity; cost[17][6]=infinity; cost[17][7]=infinity; cost[17][8]=infinity; cost[17][9]=infinity; cost[17][10]=infinity; cost[17][11]=infinity; cost[17][12]=8'd3; cost[17][13]=infinity; cost[17][14]=infinity; cost[17][15]=infinity; cost[17][16]=infinity; cost[17][17]=infinity; cost[17][18]=infinity; cost[17][19]=infinity; cost[17][20]=infinity; cost[17][21]=infinity; cost[17][22]=infinity; cost[17][23]=infinity; cost[17][24]=infinity; cost[17][25]=infinity; cost[17][26]=infinity;
			cost[18][0]=infinity; cost[18][1]=infinity; cost[18][2]=infinity; cost[18][3]=infinity; cost[18][4]=infinity; cost[18][5]=infinity; cost[18][6]=infinity; cost[18][7]=infinity; cost[18][8]=infinity; cost[18][9]=infinity; cost[18][10]=infinity; cost[18][11]=infinity; cost[18][12]=infinity; cost[18][13]=8'd2; cost[18][14]=infinity; cost[18][15]=infinity; cost[18][16]=infinity; cost[18][17]=infinity; cost[18][18]=infinity; cost[18][19]=8'd1; cost[18][20]=8'd1; cost[18][21]=infinity; cost[18][22]=infinity; cost[18][23]=infinity; cost[18][24]=infinity; cost[18][25]=infinity; cost[18][26]=infinity;
			cost[19][0]=infinity; cost[19][1]=infinity; cost[19][2]=infinity; cost[19][3]=infinity; cost[19][4]=infinity; cost[19][5]=infinity; cost[19][6]=infinity; cost[19][7]=infinity; cost[19][8]=infinity; cost[19][9]=infinity; cost[19][10]=infinity; cost[19][11]=infinity; cost[19][12]=infinity; cost[19][13]=infinity; cost[19][14]=infinity; cost[19][15]=infinity; cost[19][16]=infinity; cost[19][17]=infinity; cost[19][18]=8'd1; cost[19][19]=infinity; cost[19][20]=infinity; cost[19][21]=infinity; cost[19][22]=infinity; cost[19][23]=infinity; cost[19][24]=infinity; cost[19][25]=infinity; cost[19][26]=infinity;
			cost[20][0]=infinity; cost[20][1]=infinity; cost[20][2]=infinity; cost[20][3]=infinity; cost[20][4]=infinity; cost[20][5]=infinity; cost[20][6]=infinity; cost[20][7]=infinity; cost[20][8]=infinity; cost[20][9]=infinity; cost[20][10]=infinity; cost[20][11]=infinity; cost[20][12]=infinity; cost[20][13]=infinity; cost[20][14]=infinity; cost[20][15]=infinity; cost[20][16]=infinity; cost[20][17]=infinity; cost[20][18]=8'd1; cost[20][19]=infinity; cost[20][20]=infinity; cost[20][21]=8'd1; cost[20][22]=8'd2; cost[20][23]=infinity; cost[20][24]=infinity; cost[20][25]=infinity; cost[20][26]=infinity;
			cost[21][0]=infinity; cost[21][1]=infinity; cost[21][2]=infinity; cost[21][3]=infinity; cost[21][4]=infinity; cost[21][5]=infinity; cost[21][6]=infinity; cost[21][7]=infinity; cost[21][8]=infinity; cost[21][9]=infinity; cost[21][10]=infinity; cost[21][11]=infinity; cost[21][12]=infinity; cost[21][13]=infinity; cost[21][14]=infinity; cost[21][15]=infinity; cost[21][16]=infinity; cost[21][17]=infinity; cost[21][18]=infinity; cost[21][19]=infinity; cost[21][20]=8'd1; cost[21][21]=infinity; cost[21][22]=infinity; cost[21][23]=infinity; cost[21][24]=infinity; cost[21][25]=infinity; cost[21][26]=infinity;
			cost[22][0]=infinity; cost[22][1]=infinity; cost[22][2]=infinity; cost[22][3]=infinity; cost[22][4]=infinity; cost[22][5]=infinity; cost[22][6]=infinity; cost[22][7]=infinity; cost[22][8]=infinity; cost[22][9]=infinity; cost[22][10]=infinity; cost[22][11]=infinity; cost[22][12]=infinity; cost[22][13]=infinity; cost[22][14]=infinity; cost[22][15]=8'd1; cost[22][16]=infinity; cost[22][17]=infinity; cost[22][18]=infinity; cost[22][19]=infinity; cost[22][20]=8'd2; cost[22][21]=infinity; cost[22][22]=infinity; cost[22][23]=8'd1; cost[22][24]=infinity; cost[22][25]=8'd3; cost[22][26]=infinity;
			cost[23][0]=infinity; cost[23][1]=infinity; cost[23][2]=infinity; cost[23][3]=infinity; cost[23][4]=infinity; cost[23][5]=infinity; cost[23][6]=infinity; cost[23][7]=infinity; cost[23][8]=infinity; cost[23][9]=infinity; cost[23][10]=infinity; cost[23][11]=infinity; cost[23][12]=infinity; cost[23][13]=infinity; cost[23][14]=infinity; cost[23][15]=infinity; cost[23][16]=8'd2; cost[23][17]=infinity; cost[23][18]=infinity; cost[23][19]=infinity; cost[23][20]=infinity; cost[23][21]=infinity; cost[23][22]=8'd1; cost[23][23]=infinity; cost[23][24]=8'd2; cost[23][25]=infinity; cost[23][26]=infinity;
			cost[24][0]=infinity; cost[24][1]=infinity; cost[24][2]=infinity; cost[24][3]=infinity; cost[24][4]=infinity; cost[24][5]=infinity; cost[24][6]=infinity; cost[24][7]=infinity; cost[24][8]=infinity; cost[24][9]=infinity; cost[24][10]=infinity; cost[24][11]=infinity; cost[24][12]=infinity; cost[24][13]=infinity; cost[24][14]=infinity; cost[24][15]=infinity; cost[24][16]=infinity; cost[24][17]=infinity; cost[24][18]=infinity; cost[24][19]=infinity; cost[24][20]=infinity; cost[24][21]=infinity; cost[24][22]=infinity; cost[24][23]=8'd2; cost[24][24]=infinity; cost[24][25]=infinity; cost[24][26]=infinity;
			cost[25][0]=infinity; cost[25][1]=infinity; cost[25][2]=infinity; cost[25][3]=infinity; cost[25][4]=infinity; cost[25][5]=infinity; cost[25][6]=infinity; cost[25][7]=infinity; cost[25][8]=infinity; cost[25][9]=infinity; cost[25][10]=infinity; cost[25][11]=infinity; cost[25][12]=infinity; cost[25][13]=infinity; cost[25][14]=infinity; cost[25][15]=infinity; cost[25][16]=infinity; cost[25][17]=infinity; cost[25][18]=infinity; cost[25][19]=infinity; cost[25][20]=infinity; cost[25][21]=infinity; cost[25][22]=8'd3; cost[25][23]=infinity; cost[25][24]=infinity; cost[25][25]=infinity; cost[25][26]=infinity;
			cost[26][0]=infinity; cost[26][1]=infinity; cost[26][2]=infinity; cost[26][3]=infinity; cost[26][4]=infinity; cost[26][5]=infinity; cost[26][6]=infinity; cost[26][7]=infinity; cost[26][8]=infinity; cost[26][9]=infinity; cost[26][10]=infinity; cost[26][11]=infinity; cost[26][12]=infinity; cost[26][13]=infinity; cost[26][14]=infinity; cost[26][15]=infinity; cost[26][16]=infinity; cost[26][17]=infinity; cost[26][18]=infinity; cost[26][19]=infinity; cost[26][20]=infinity; cost[26][21]=infinity; cost[26][22]=infinity; cost[26][23]=infinity; cost[26][24]=infinity; cost[26][25]=infinity; cost[26][26]=infinity;
					
			temp_path[0]=5'd0;
			temp_path[1]=5'd0;
			temp_path[2]=5'd0;
			temp_path[3]=5'd0;
			temp_path[4]=5'd0;
			temp_path[5]=5'd0;
			temp_path[6]=5'd0;
			temp_path[7]=5'd0;
			temp_path[8]=5'd0;
			temp_path[9]=5'd0;

			done=1'b1;
			state=path_out;
							  
								
		  end	
					
					
		 // assign output
		 path_out: begin  
		  final_path[49:45]=temp_path[0];
		  final_path[44:40]=temp_path[1];
		  final_path[39:35]=temp_path[2];
		  final_path[34:30]=temp_path[3];
		  final_path[29:25]=temp_path[4];
		  final_path[24:20]=temp_path[5];
		  final_path[19:15]=temp_path[6];
		  final_path[14:10]=temp_path[7];
		  final_path[9:5]=temp_path[8];
		  final_path[4:0]=temp_path[9];

		  if(start) begin
			done=1'b0; state=initial_distance;
		  end
		  else state=path_out;
							
							
		end


		// logic based on dijsktra algorithm using fsm
						  
		 initial_distance: begin   
								
			 if(counter==8'd27) begin
				counter = 8'd0;
				distance[s_node] = 8'd0;
				visited[s_node]  = 8'd1;
				count = 8'd1;
				mindistance = infinity;
				state = nextnode_finder;
			 end
	
			else begin
				if(counter<10) begin
					temp_path[counter]=5'd27;
				end
				distance[counter]=cost[s_node][counter];
				visited[counter]=8'd0;
				pred[counter] = s_node;
				counter <= counter + 8'd1;
				state <=initial_distance;
			end
								
		end		
		 
		 nextnode_finder:	begin
		 
			if(count==8'd26) begin 
				t = e_node;
				counter =8'd0;
				x=4'd8;
				temp_path[9]=e_node;
				state = path_tracing; 
			end
			

			else if(counter==8'd27)begin
				counter =8'd0;
				visited[nextnode]=8'd1;
				state = path_updater;
			end
			
			else begin
			
			  if(distance[counter] < mindistance && !visited[counter])begin
					mindistance = distance[counter];
					nextnode = counter;
			  end
			 
				counter = counter+8'd1;
				state = nextnode_finder;
			end
		 end		
								

		 path_updater: begin
			if(counter==8'd27) begin
				counter=8'd0;
				count = count + 8'd1;
				mindistance = infinity;
				state = nextnode_finder;
			end
			
			else begin
			  if(!visited[counter]) begin
				 if (mindistance + cost[nextnode][counter] < distance[counter])begin
					distance[counter] = mindistance + cost[nextnode][counter];
					pred[counter]=nextnode;
				 end
			  end
			  counter = counter+8'd1;
			  state = path_updater;
			end
		 end			
								
		path_tracing: begin
		  if(t!=s_node && counter<=8'd26)begin		  
			  t=pred[t];
			  counter =counter+8'd1;
			  temp_path[x]=t;
			  x=x-4'd1;
			  state = path_tracing;
		  end
		  
		  else begin
			  counter = 8'd0;
			  done = 1'b1;
			  state = path_out;
		  end
		end	  
						
		 
	endcase
 
end

////////////////////////YOUR CODE ENDS HERE//////////////////////////
endmodule
///////////////////////////////MODULE ENDS///////////////////////////