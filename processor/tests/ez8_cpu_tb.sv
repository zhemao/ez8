module ez8_cpu_tb ();

reg clk = 1'b1;
reg reset;
reg pause;

reg [11:0] instr_writeaddr;
reg [15:0] instr_writedata;
reg instr_write_en;
wire [7:0] accum;

ez8_cpu cpu (
    .clk (clk),
    .reset (reset),
    .pause (pause),
    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en (instr_write_en),
    .accum_out (accum)
);

always #10000 clk = !clk;

initial begin
    reset = 1'b0;
    pause = 1'b1;
    instr_writeaddr = 12'd0;
    instr_writedata = 16'h4050;
    instr_write_en = 1'b1;

    #20000 instr_writeaddr = 12'd1;
    instr_writedata = 16'h0101;
    #20000 instr_writeaddr = 12'd2;
    instr_writedata = 16'h4100;
    #20000 instr_writeaddr = 12'd3;
    instr_writedata = 16'h2100;
    #20000 instr_writeaddr = 12'd4;
    instr_writedata = 16'h6148;
    #20000 instr_writeaddr = 12'd5;
    instr_writedata = 16'h800a;
    #20000 instr_writeaddr = 12'd6;
    instr_writedata = 16'h6050;
    #20000 instr_writeaddr = 12'ha;
    instr_writedata = 16'h6060;
    #20000 instr_write_en = 1'b0;
    pause = 1'b0;
    reset = 1'b1;
    #20000 reset = 1'b0;
    #200000 pause = 1'b1;
    #20000 assert (accum == 8'd7);
end

endmodule
