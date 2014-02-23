module sockit_top (
    input OSC_50_B3B,
    input RESET_n,

    input  [3:0] KEY,
    input  [3:0] SW,
    output [3:0] LED
);

wire pause = 1'b0;

wire [11:0] instr_writeaddr = 12'd0;
wire [15:0] instr_writedata = 16'd0;
wire instr_write_en = 1'b0;

ez8_cpu cpu (
    .clk (OSC_50_B3B),
    .reset (!RESET_n),
    .pause (pause),

    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en  (instr_write_en),

    .keys (KEY),
    .switches (SW),
    .leds (LED)
);

endmodule
