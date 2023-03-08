



module uart_test(input clk_50M, input rst_n, output tx);

wire tx_temp;
 

uart uart_obj(.rst_n(rst_n), .clk_50M(clk_50M), .in_data(8'h4D), .tx(tx_temp));

assign tx=tx_temp;

endmodule

