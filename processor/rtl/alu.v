module alu (
    input [3:0] opcode,
    input [7:0] operand,
    input [7:0] regvalue,
    input [7:0] accum,
    input [2:0] selector,
    input direction,
    input cin,

    output reg [7:0] result,
    output accum_write,
    output reg_write,
    output reg_addr,
    output z_write,
    output zout,
    output c_write,
    output cout
);

wire [7:0] a = (opcode[3]) ? regvalue : accum;
wire [7:0] b = (opcode[2]) ? operand : regvalue;
wire [7:0] as_res;

addsub as (
    .a (a),
    .b (b),
    .cin (cin),
    .sub (selector[2]),
    .take_carry (selector[1]),
    .sum (as_res),
    .cout (cout)
);

wire bw_a_sel = (opcode == 4'b1111 && direction) ||
                (opcode == 4'b0000 && !direction) ||
                 opcode == 4'b0100;
wire bw_b_sel = (opcode == 4'b0000 || opcode == 4'b0100 || opcode[3:1] == 3'b111);
wire bw_res;

bitwise bw (
    .a (a),
    .b (b),
    .op_sel (selector[2:1]),
    .a_sel (bw_a_sel),
    .b_sel (bw_b_sel),
    .res (bw_res)
);

wire shift_res;

shifter shift (
    .shift_in (a),
    .shift_by (b[2:0]),
    .lr (selector[2]),
    .arith (selector[1]),
    .shift_out (shift_res)
);

always @(*) begin
    case (opcode[1:0])
        2'b01: result <= shift_res;
        2'b10: result <= as_res;
        default: result <= bw_res;
    endcase
end

wire write_out = (opcode[3:2] == 2'b10 || opcode[3:1] == 3'b110);
assign reg_write = write_out && direction;
assign accum_write = write_out && !direction;
assign z_write = (opcode[3] == 1'b0 && opcode[1:0] != 2'b00);
assign c_write = (opcode[3] == 1'b0 && opcode[1:0] == 2'b10);
assign zout = (result == 8'd0);

endmodule
