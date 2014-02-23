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

integer fd;

initial begin
    pause = 1'b1;
    instr_write_en = 1'b1;
    instr_writeaddr = 12'd0;

    fd = $fopen("../../../tests/arithmetic.bin", "r");

    if (fd == 0) begin
        $error("Invalid file");
    end

    while ($fread(instr_writedata, fd)) begin
        #20000 instr_writeaddr = instr_writeaddr + 1'b1;
    end

    $fclose(fd);

    reset = 1'b1;
    pause = 1'b0;
    instr_write_en = 1'b0;
    #20000 reset = 1'b0;

    #1160000 assert (stopped);

    assert (!error);
    assert (accum == 8'd0);
end

endmodule
