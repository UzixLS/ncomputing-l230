module vgaout#(
    parameter VRAM_DELAY = 2,
    parameter BITS = 1,
    parameter PIXELS = 800,
    parameter H_FRONT_PORCH = 56,
    parameter HSYNC_LEN = 120,
    parameter H_BACK_PORCH = 64,
    parameter LINES = 600,
    parameter V_FRONT_PORCH = 37,
    parameter VSYNC_LEN = 6,
    parameter V_BACK_PORCH = 23,
    parameter HSYNC_NEG = 1'b0,
    parameter VSYNC_NEG = 1'b0
    ) (
    input clk,
    input rst_n,
    
    output wire [$clog2(PIXELS)-1:0] vram_h,
    output wire [$clog2(LINES)-1:0] vram_v,
    output wire vram_read,
    input wire [3*BITS-1:0] vram_data,
    
    output reg vblank,
    output wire rgb_en,
    
    output reg hsync,
    output reg vsync,
    output reg [BITS-1:0] r,
    output reg [BITS-1:0] g,
    output reg [BITS-1:0] b
    );
    

reg [$clog2(PIXELS+H_FRONT_PORCH+HSYNC_LEN+H_BACK_PORCH)-1:0] hcnt;
reg [$clog2(LINES+V_FRONT_PORCH+VSYNC_LEN+V_BACK_PORCH)-1:0] vcnt;

wire [BITS-1:0] vram_r, vram_g, vram_b;
assign {vram_r, vram_g, vram_b} = vram_data;

assign vram_h = hcnt - HSYNC_LEN - H_FRONT_PORCH + VRAM_DELAY;
assign vram_v = vcnt;
assign vram_read = (vcnt < LINES) && (hcnt >= HSYNC_LEN + H_FRONT_PORCH - VRAM_DELAY)
    && (hcnt < HSYNC_LEN + H_FRONT_PORCH + PIXELS);

assign rgb_en = (vcnt < LINES) && (hcnt >= HSYNC_LEN + H_FRONT_PORCH)
    && (hcnt < HSYNC_LEN + H_FRONT_PORCH + PIXELS);


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        hcnt <= 1'b0;
        vcnt <= 1'b0;
        vblank <= 1'b0;
        hsync <= 1'b0;
        vsync <= 1'b0;
        r <= 1'b0;
        g <= 1'b0;
        b <= 1'b0;
    end else begin
        if (hcnt == PIXELS + H_FRONT_PORCH + HSYNC_LEN + H_BACK_PORCH - 1) begin
            hcnt <= 1'b0;
            if (vcnt == LINES + V_FRONT_PORCH + VSYNC_LEN + V_BACK_PORCH - 1) begin
                vcnt <= 1'b0;
            end else begin
                vcnt <= vcnt + 1'b1;
            end
        end else begin
            hcnt <= hcnt + 1'b1;
            vcnt <= vcnt;
        end
        
        vblank <= (vcnt >= LINES);
        
        hsync <= HSYNC_NEG ^ (hcnt < HSYNC_LEN);
                
        vsync <= VSYNC_NEG ^ (vcnt >= LINES + V_FRONT_PORCH
                && vcnt < LINES + V_FRONT_PORCH + VSYNC_LEN);
                
        if (rgb_en) begin
            r <= vram_r;
            g <= vram_g;
            b <= vram_b;
        end else begin
            r <= 1'b0;
            g <= 1'b0;
            b <= 1'b0;
        end
    
    end
end


endmodule
