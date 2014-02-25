module shifter (
    input signed [7:0] shift_in,
    input [2:0] shift_by,
    // 0 for left, 1 for right
    input lr,
    // 0 for logical, 1 for arithmetic
    input arith,
    output reg signed [7:0] shift_out
);

always @(*) begin
    if (!lr)
        shift_out = shift_in << shift_by;
    else if (arith)
        shift_out = shift_in >>> shift_by;
    else
        shift_out = shift_in >> shift_by;
end

endmodule
