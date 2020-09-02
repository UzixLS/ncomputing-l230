module top(
	input clk_a,
	input clk_b,

	output led_center,
	output led_right,

	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b,
	output vga_hsync,
	output vga_vsync,

	output keyboard_clk,
	inout keyboard_dat,
	output mouse_clk,
	inout mouse_dat,

	output snd_l,
	output snd_r,
	input pcm_dout,
	output pcm_scki,
	inout pcm_lrck,
	inout pcm_bck,

	input eth_txc,
	output eth_txen,
	output [3:0] eth_txd,
	input eth_rxc,
	input eth_col,
	input eth_crs,
	input eth_rxdv,
	input [3:0] eth_rxd,
	input eth_rxer,
	output eth_mdc,
	inout eth_mdio,
	output eth_x1,

	inout usb_dp,
	inout usb_dn,

	output dram_we,
	output dram_cas,
	output dram_ras,
	output dram_cs,
	output dram_clk,
	output [3:0] dram_dqm,
	inout [31:0] dram_dq,
	output [1:0] dram_ba,
	output [11:0] dram_a,
	
	inout [12:0] max
);


wire pll_locked;
wire rst_n = pll_locked;
wire clk_80mhz = clk_a;
wire clk_50mhz;
pll1 pll1(.inclk0(clk_80mhz), .c0(clk_50mhz), .locked(pll_locked));

reg [24:0] cnt;
wire clk_1hz = cnt[24];
wire clk_3hz = cnt[23];
wire clk_760khz = cnt[15];
always @(posedge clk_50mhz or negedge rst_n) begin
	if (!rst_n)
		cnt <= 0;
	else
		cnt <= cnt + 1'b1;
end

assign led_center = clk_1hz;
assign led_right = clk_3hz;

reg x;
always @(posedge clk_760khz or negedge rst_n) begin
	if(!rst_n)
		x <= 0;
	else
		x <= ~x;
end

wire [9:0] vram_h, vram_v;
wire [23:0] vram_data = {
vram_h[7], vram_h[6], vram_h[5], vram_h[4], vram_h[3], vram_h[2], vram_h[1], vram_h[0], 
vram_v[7], vram_v[6], vram_v[5], vram_v[4], vram_v[3], vram_v[2], vram_v[1], vram_v[0], 
vram_v[7], vram_v[6], vram_v[5], vram_v[4], vram_v[3], vram_v[2], vram_v[1], vram_v[0], 
};

vgaout #(.BITS(8), .VRAM_DELAY(5)) vgaout1(
	.clk(clk_50mhz),
	.rst_n(rst_n),
	.hsync(vga_hsync),
	.vsync(vga_vsync),
	.r(vga_r),
	.g(vga_g),
	.b(vga_b),
	.vram_h(vram_h),
	.vram_v(vram_v),
	.vram_data(vram_data)
);


reg sdram_req;
wire sdram_ack;
wire [21:0] sdram_addr;
wire [31:0] sdram_data_in;
wire [31:0] sdram_data_out;
wire sdram_wren = 0;
wire sdram_rfsh = 0;
sdram sdram1(
	.clk(clk_80mhz),
	.reset(~rst_n),
	.refresh(sdram_rfsh),

	.memAddress(sdram_addr),
	.memDataIn(sdram_data_in),
	.memDataOut(sdram_data_out),
	.memDataMask(4'b1111),
	.memWr(sdram_wren),
	.memReq(sdram_req),
	.memAck(sdram_ack),

	.pMemClk(dram_clk),
	.pMemCs_n(dram_cs),
	.pMemRas_n(dram_ras),
	.pMemCas_n(dram_cas),
	.pMemWe_n(dram_we),
	.pMemBa1(dram_ba[1]),
	.pMemBa0(dram_ba[0]),
	.pMemAdr(dram_a),
	.pMemDat(dram_dq),
	.pMemDqm(dram_dqm)
);


reg [8:0] snd_l_acc, snd_r_acc;
reg [7:0] snd_l_data, snd_r_data;
assign snd_l = snd_l_acc[8];
assign snd_r = snd_r_acc[8];
always @(posedge clk_50mhz or negedge rst_n) begin
	if (!rst_n) begin
		snd_l_data <= 0;
		snd_r_data <= 0;
		snd_l_acc <= 0;
		snd_r_acc <= 0;
	end
	else begin
		snd_l_acc <= snd_l_acc[7:0] + snd_l_data;
		snd_r_acc <= snd_r_acc[7:0] + snd_r_data;
	end
end


endmodule
