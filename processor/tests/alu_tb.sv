module alu_tb ();

reg [3:0] opcode;
reg [7:0] operand;
reg [7:0] regvalue;
reg [7:0] accum;
reg [2:0] selector;
reg direction;
reg cin;

wire [7:0] result;
wire accum_write;
wire reg_write;
wire z_write;
wire zout;
wire c_write;
wire cout;

alu alu0 (
    .opcode (opcode),
    .operand (operand),
    .regvalue (regvalue),
    .accum (accum),
    .selector (selector),
    .direction (direction),
    .cin (cin),
    .result (result),
    .accum_write (accum_write),
    .reg_write (reg_write),
    .zout (zout),
    .z_write (z_write),
    .c_write (c_write),
    .cout (cout)
);

initial begin
    // GET
    opcode = 4'b0000;
    direction = 1'b0;
    regvalue = 8'd12;
    selector = 3'b000;
    #20000 assert (result == regvalue);
    assert (accum_write);
    assert (!reg_write);
    assert (!z_write);
    assert (!c_write);

    // PUT
    direction = 1'b1;
    accum = 8'd10;
    #20000 assert (result == accum);
    assert (!accum_write);
    assert (reg_write);
    assert (!z_write);
    assert (!c_write);

    // SLL
    opcode = 4'b0001;
    selector = 3'b000;
    accum = 8'h02;
    regvalue = 8'd4;
    direction = 1'b0;
    #20000 assert (result == 8'h20);
    assert (accum_write);
    assert (!reg_write);
    assert (z_write);
    assert (!zout);
    assert (!c_write);

    direction = 1'b1;
    // make sure result is same, but writing to register instead of accumulator
    #20000 assert (result == 8'h20);
    assert (!accum_write);
    assert (reg_write);

    // SLLL
    opcode = 4'b0101;
    operand = 8'd3;
    direction = 1'b0;
    #20000 assert (result == 8'h10);
    assert (accum_write);
    assert (!reg_write);

    // SRL
    opcode = 4'b0001;
    selector = 3'b100;
    accum = 8'h40;
    regvalue = 8'd7;
    direction = 1'b0;
    #20000 assert (result == 8'd0);
    assert (accum_write);
    assert (!reg_write);
    assert (z_write);
    assert (zout);
    assert (!c_write);

    // SRLL
    accum = 8'h80;
    regvalue = 8'd2;
    opcode = 4'b0101;
    direction = 1'b0;
    #20000 assert (result == 8'h10);
    assert (accum_write);
    assert (!reg_write);

    // SRA
    opcode = 4'b0001;
    selector = 3'b110;
    direction = 1'b0;
    regvalue = 8'd7;
    #20000 assert (result == 8'hff);
    assert (accum_write);
    assert (!reg_write);
    assert (z_write);
    assert (!zout);
    assert (!c_write);

    // SRAL
    opcode = 4'b0101;
    regvalue = 8'd2;
    direction = 1'b0;
    #20000 assert (result == 8'hf0);
    assert (accum_write);
    assert (!reg_write);

    // ADD
    opcode = 4'b0010;
    operand = 8'd28;
    regvalue = 8'd10;
    accum = 8'd228;
    selector = 3'b000;
    direction = 1'b0;
    #20000 assert (result == 8'd238);
    assert (z_write);
    assert (!zout);
    assert (c_write);
    assert (!cout);

    // ADDL
    opcode = 4'b0110;
    #20000 assert (result == 8'd0);
    assert (z_write);
    assert (zout);
    assert (c_write);
    assert (cout);

    // ADC
    opcode = 4'b0010;
    selector = 3'b010;
    cin = 1'b1;
    #20000 assert (result == 8'd239);
    assert (z_write);
    assert (!zout);
    assert (c_write);
    assert (!cout);

    // ADCL
    opcode = 4'b0110;
    #20000 assert (result == 8'd1);
    assert (z_write);
    assert (!zout);
    assert (c_write);
    assert (cout);

    // SUB
    opcode = 4'b0010;
    selector = 3'b100;
    #20000 assert (result == 8'd218);

    // SUBL
    opcode = 4'b0110;
    #20000 assert (result == 8'd200);

    // AND
    opcode = 4'b0011;
    selector = 3'b000;
    accum = 8'h05;
    regvalue = 8'h03;
    operand = 8'h0c;
    direction = 1'b1; // just for kicks
    #20000 assert (result == 8'h01);

    // ANDL
    opcode = 4'b0111;
    #20000 assert (result == 8'h04);

    // IOR
    opcode = 4'b0011;
    selector = 3'b010;
    #20000 assert (result == 8'h07);

    // IORL
    opcode = 4'b0111;
    #20000 assert (result == 8'h0d);

    // XOR
    opcode = 4'b0011;
    selector = 3'b100;
    #20000 assert (result == 8'h06);

    // XORL
    opcode = 4'b0111;
    #20000 assert (result == 8'h09);

    // SET
    opcode = 4'b0100;
    selector = 3'b000;
    operand = 8'd12;
    #20000 assert (result == 8'd12);

    // CLR
    opcode = 4'b1111;
    selector = 3'b000;
    #20000 assert (result == 8'd0);

    // COM
    selector = 3'b100;
    regvalue = 8'hac;
    direction = 1'b1;
    #20000 assert (result == 8'h53);
end

endmodule
