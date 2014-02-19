module sockit_top (
    input OSC_50_B3B
);

alu a (
    .opcode (4'd0),
    .operand (8'd0),
    .regvalue (8'd0),
    .accum (8'd0),
    .selector (3'd0),
    .direction (1'b0),
    .cin (1'b0)
);

skip_calc sc (
    .opcode (2'b0),
    .reg_value (8'd0),
    .accum_value (8'd0),
    .selector (3'b0),
    .direction (1'b0)
);

endmodule
