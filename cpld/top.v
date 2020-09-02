module top(
	input clk,

	output flash_si,
	output flash_reset,
	output flash_wp,
	output flash_cs,
	output flash_sck,
	input flash_so,
	
	output cy_dclk,
	output cy_data0,
	input cy_nconfig,
	input cy_conf_done,

	inout [12:0] cy
);

assign flash_si = 0;
assign flash_reset = 0;
assign flash_wp = 0;
assign flash_cs = 1'b1;
assign flash_sck = 0;

assign cy_dclk = 0;
assign cy_data0 = 0;

endmodule
