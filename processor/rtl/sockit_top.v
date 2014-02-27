module sockit_top (
    input OSC_50_B3B,
    input RESET_n,

    input  [3:0] KEY,
    input  [3:0] SW,
    output [3:0] LED
);

wire pause = 1'b0;
wire cpu_reset = !RESET_n;
wire master_clk = OSC_50_B3B;

wire [11:0] instr_writeaddr = 12'd0;
wire [15:0] instr_writedata = 16'd0;
wire instr_write_en = 1'b0;

wire [7:0] io_writedata;
wire [4:0] io_writeaddr;
wire io_write_en;
wire [7:0] io_readdata;
wire [4:0] io_readaddr;
wire [7:0] io_interrupts;

ez8_cpu cpu (
    .clk (master_clk),
    .reset (cpu_reset),
    .pause (pause),

    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en  (instr_write_en),

    .io_readaddr (io_readaddr),
    .io_readdata (io_readdata),
    .io_writeaddr (io_writeaddr),
    .io_writedata (io_writedata),
    .io_write_en (io_write_en),
    .io_interrupts (io_interrupts)
);

io_ctrl io (
    .clk (master_clk),
    .reset (cpu_reset),

    .readaddr (io_readaddr),
    .readdata (io_readdata),
    .writeaddr (io_writeaddr),
    .writedata (io_writedata),
    .write_en (io_write_en),
    .interrupts (io_interrupts),

    .switches (SW),
    .keys (KEY),
    .leds (LED)
);

endmodule
