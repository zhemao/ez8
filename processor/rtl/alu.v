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
    output z_write,
    output zout,
    output c_write,
    output cout,
    output retint,
    output skip
);

parameter CLR_COM_OPCODE = 4'b1111;
parameter GET_PUT_OPCODE = 4'b0000;
parameter SET_OPCODE = 4'b0100;
parameter RET_OPCODE = 4'b1101;
parameter INDIR_OPCODE = 4'b1110;

wire [7:0] a = accum;
// immediate instructions and ret instructions use the operand
wire [7:0] b = (opcode[3:2] == 2'b01) ? operand : regvalue;
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

wire bw_a_sel = (opcode == CLR_COM_OPCODE && direction) ||
                (opcode == GET_PUT_OPCODE && !direction) ||
                (opcode == INDIR_OPCODE && !direction) ||
                 opcode == SET_OPCODE || opcode == RET_OPCODE;
wire [1:0] bw_b_sel;
assign bw_b_sel[0] =
    (opcode == GET_PUT_OPCODE || opcode == SET_OPCODE ||
     opcode == INDIR_OPCODE ||
     opcode == RET_OPCODE || opcode == CLR_COM_OPCODE);
assign bw_b_sel[1] = (opcode == CLR_COM_OPCODE && !selector[2]);
wire [7:0] bw_res;

bitwise bw (
    .a (a),
    .b (b),
    .op_sel (selector[2:1]),
    .a_sel (bw_a_sel),
    .b_sel (bw_b_sel),
    .res (bw_res)
);

wire [7:0] shift_res;

shifter shift (
    .shift_in (a),
    .shift_by (b[2:0]),
    .lr (selector[2]),
    .arith (selector[1]),
    .shift_out (shift_res)
);

always @(*) begin
    // unfortunately, indirects are a special case
    if (opcode == INDIR_OPCODE)
        result = bw_res;
    else case (opcode[1:0])
        2'b01: result = shift_res;
        2'b10: result = as_res;
        default: result = bw_res;
    endcase
end

parameter SKBC_OPCODE = 4'b1100;

wire write_out = !(opcode[3:2] == 2'b10 ||
                   opcode == SKBC_OPCODE ||
                   opcode == RET_OPCODE);
assign reg_write = write_out && direction;
assign accum_write = write_out && !direction;
assign z_write = (opcode[3] == 1'b0 && opcode[1:0] != 2'b00);
assign c_write = (opcode[3] == 1'b0 && opcode[1:0] == 2'b10);
assign zout = (result == 8'd0);
assign retint = (opcode == RET_OPCODE && selector[2] == 1'b1);

skip_calc sc (
    .opcode (opcode),
    .reg_value (regvalue),
    .accum_value (accum),
    .selector (selector),
    .direction (direction),
    .skip (skip)
);

endmodule
