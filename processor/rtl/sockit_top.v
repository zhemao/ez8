module sockit_top (
    input OSC_50_B3B
);

wire cpu_reset;
wire [11:0] instr_writeaddr = 12'd0;
wire [15:0] instr_writedata = 16'd0;
wire instr_write_en = 1'b0;
wire [7:0] accum;

ez8_cpu cpu (
    .clk (OSC_50_B3B),
    .reset (cpu_reset),

    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en  (instr_write_en),

    .accum_out (accum)
);

endmodule
