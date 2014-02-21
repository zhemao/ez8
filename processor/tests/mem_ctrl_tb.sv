module mem_ctrl_tb ();

reg clk = 1'b1;
reg zin;
reg z_write;
reg cin;
reg c_write;
wire cout;

reg [7:0] writeaddr;
reg [7:0] writedata;
reg write_en;
reg [7:0] readaddr;
wire [7:0] readdata;

reg [7:0] accum_in;
reg accum_write;
wire [7:0] accum_out;

mem_ctrl mc (
    .clk (clk),
    .zin (zin),
    .z_write (z_write),
    .cin (cin),
    .c_write (c_write),
    .cout (cout),
    .writeaddr (writeaddr),
    .writedata (writedata),
    .write_en (write_en),
    .readaddr (readaddr),
    .readdata (readdata),
    .accum_in (accum_in),
    .accum_write (accum_write),
    .accum_out (accum_out)
);

always #10000 clk = !clk;

initial begin
    z_write = 1'b0;
    c_write = 1'b0;
    accum_write = 1'b0;

    // write then read
    write_en = 1'b1;
    writeaddr = 8'h10;
    writedata = 8'd32;
    #20000 readaddr = 8'h10;
    write_en = 1'b0;
    #20000 assert (readdata == 8'd32);

    // write and read same address
    write_en = 1'b1;
    writedata = 8'd31;
    #20000 assert (readdata == 8'd31);

    // change bank and set c
    writeaddr = 8'h01;
    writedata = 8'b00100010;
    #20000 assert (cout == 1'b1);

    // write to the new bank
    writeaddr = 8'h10;
    writedata = 8'd12;
    #20000 assert (readdata == 8'd12);

    // change bank back to 0
    writeaddr = 8'h01;
    writedata = 8'd0;
    // make sure value in old bank was unchanged
    #20000 assert (readdata == 8'd31);
    write_en = 1'b0;
    #20000 assert (readdata == 8'd31);

    // go back to bank 1 and make sure that value is also still there
    write_en = 1'b1;
    writeaddr = 8'h01;
    writedata = 8'b00100000;
    
    #20000 write_en = 1'b0;
    #20000 assert (readdata == 8'd12);

    c_write = 1'b1;
    cin = 1'b1;
    #20000 assert (cout == 1'b1);

    c_write = 1'b0;
    z_write = 1'b1;
    zin = 1'b1;
    readaddr = 8'h01;
    #20000 assert (readdata == 8'b00100011);
    z_write = 1'b0;

    accum_in = 8'd20;
    accum_write = 1'b1;
    #20000 assert (accum_out == 8'd20);
    accum_write = 1'b0;
    #20000 assert (accum_out == 8'd20);

end

endmodule
