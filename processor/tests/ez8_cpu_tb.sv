module ez8_cpu_tb ();

reg clk = 1'b1;
reg reset;
reg pause;

reg [3:0] keys;
reg [3:0] switches;
wire [3:0] leds;

reg [11:0] instr_writeaddr;
reg [15:0] instr_writedata;
reg instr_write_en;
wire [7:0] accum;
wire error;
wire stopped;

wire [7:0] io_writedata;
wire [4:0] io_writeaddr;
wire io_write_en;
wire [7:0] io_readdata;
wire [4:0] io_readaddr;
wire [7:0] io_interrupts;

ez8_cpu cpu (
    .clk (clk),
    .reset (reset),
    .pause (pause),

    .error (error),
    .stopped (stopped),

    .io_readaddr (io_readaddr),
    .io_readdata (io_readdata),
    .io_writeaddr (io_writeaddr),
    .io_writedata (io_writedata),
    .io_write_en (io_write_en),
    .io_interrupts (io_interrupts),

    .instr_writeaddr (instr_writeaddr),
    .instr_writedata (instr_writedata),
    .instr_write_en (instr_write_en),
    .accum_out (accum)
);

io_ctrl io (
    .clk (clk),
    .reset (cpu_reset),

    .readaddr (io_readaddr),
    .readdata (io_readdata),
    .writeaddr (io_writeaddr),
    .writedata (io_writedata),
    .write_en (io_write_en),
    .interrupts (io_interrupts),

    .switches (switches),
    .keys (switches),
    .leds (leds)
);

always #10000 clk = !clk;

integer fds [0:3];
integer i;

initial begin

    fds[0] = $fopen("../../../tests/arithmetic.bin", "r");
    fds[1] = $fopen("../../../tests/skips.bin", "r");
    fds[2] = $fopen("../../../tests/banks.bin", "r");
    fds[3] = $fopen("../../../tests/indirect.bin", "r");

    for (i = 0; i < 4; i = i + 1) begin
        if (fds[i] == 0) begin
            $error("Invalid file");
        end

        pause = 1'b1;
        instr_write_en = 1'b1;
        instr_writeaddr = 12'd0;

        while ($fread(instr_writedata, fds[i])) begin
            #20000 instr_writeaddr = instr_writeaddr + 1'b1;
        end

        $fclose(fds[i]);

        keys = 4'hf;
        switches = 4'h0;

        reset = 1'b1;
        pause = 1'b0;
        instr_write_en = 1'b0;
        #20000 reset = 1'b0;

        while (!stopped) begin
            if ($urandom_range(9, 0) == 0)
                keys[0] = 1'b0;
            #20000 keys[0] = 1'b1;
        end

        assert (!error);
        assert (accum == 8'd0);
    end
end

endmodule
