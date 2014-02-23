module ez8_cpu_tb ();

reg clk = 1'b1;
reg reset;
reg pause;

reg [11:0] instr_writeaddr;
reg [15:0] instr_writedata;
reg instr_write_en;
wire [7:0] accum;
wire error;
wire stopped;

ez8_cpu cpu (
    .clk (clk),
    .reset (reset),
    .pause (pause),

    .error (error),
    .stopped (stopped),

    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en (instr_write_en),
    .accum_out (accum)
);

always #10000 clk = !clk;

initial begin
    reset = 1'b1;
    pause = 1'b0;
    instr_write_en = 1'b0;
    #20000 reset = 1'b0;

    #1160000 assert (stopped);

    assert (!error);
    assert (accum == 8'd0);
end

endmodule
