module sockit_top (
    input OSC_50_B3B
);

addsub as (
    .a (8'd0),
    .b (8'd0),
    .cin (1'b0),
    .sub (1'b0),
    .take_carry (1'b0)
);

shifter shft (
    .shift_in (8'd0),
    .shift_by (3'd0),
    .lr (1'b0),
    .arith (1'b0)
);

bitwise bw (
    .a (8'd0),
    .b (8'd0),
    .op_sel (2'd0),
    .a_sel (1'b0),
    .b_sel (1'b0)
);

skip_calc sc (
    .opcode (2'b0),
    .reg_value (8'd0),
    .accum_value (8'd0),
    .selector (3'b0),
    .direction (1'b0)
);

endmodule
