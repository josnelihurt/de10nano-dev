module custom_leds(
    input  logic        clk,                // clock.clk
    input  logic        reset,              // reset.reset
    
    // Memory mapped read/write slave interface
    input  logic        avs_s0_address,     // avs_s0.address
    input  logic        avs_s0_read,        // avs_s0.read
    input  logic        avs_s0_write,       // avs_s0.write
    output logic [31:0] avs_s0_readdata,    // avs_s0.readdata
    input  logic [31:0] avs_s0_writedata,   // avs_s0.writedata
    
    // The LED outputs
    output logic [7:0]  leds,
	// VGA This is the mister FPGA example board
	output  [5:0] io_vga_r,
	output  [5:0] io_vga_g,
	output  [5:0] io_vga_b,
	output         io_vga_hs,  // VGA_HS is secondary SD card detect when VGA_EN = 1 (inactive)
	output		  io_vga_vs
);

reg [2:0] grid_color_reg;

// Read operations performed on the Avalon-MM Slave interface
always_comb begin
    if (avs_s0_read) begin
        case (avs_s0_address)
            1'b0    : avs_s0_readdata = {24'b0, leds};
            default : avs_s0_readdata = 'x;
        endcase
    end else begin
        avs_s0_readdata = 'x;
    end
end

// Write operations performed on the Avalon-MM Slave interface
always_ff @ (posedge clk) begin
    if (reset) begin
        leds <= '0;
        grid_color_reg <= '0;
    end else if (avs_s0_write) begin
        grid_color_reg <= grid_color_reg;
        case (avs_s0_address)
            1'h0000_0000    : leds <= avs_s0_writedata;
            1'h0000_0001    : grid_color_reg <= avs_s0_writedata[2:0];
            default         : leds <= leds;
        endcase
    end
end


wire video_on;
wire [9:0] pixel_x, pixel_y;
wire o_vga_hs, o_vga_vs;

//VGA sync device
vga_sync vga_sync_u0(
    .clk(clk), .reset(reset),.hsync(o_vga_hs), .vsync(o_vga_vs),
	.video_on(video_on), .p_tick(p_tick),.pixel_x(pixel_x),.pixel_y(pixel_y)
    );

wire [2:0] rgb;
	
grid_graph_dot_an grid_g_u0(
	.clk(clk), .video_on(video_on), .grid_color(grid_color_reg),
    .pix_x(pixel_x), .pix_y(pixel_y), .graph_rgb(rgb)
	);

assign io_vga_r = {rgb[0],rgb[0],rgb[0],rgb[0],rgb[0],rgb[0]};
assign io_vga_g = {rgb[1],rgb[1],rgb[1],rgb[1],rgb[1],rgb[1]};
assign io_vga_b = {rgb[2],rgb[2],rgb[2],rgb[2],rgb[2],rgb[2]};
assign io_vga_hs = o_vga_hs;
assign io_vga_vs = o_vga_vs;



endmodule // custom_leds