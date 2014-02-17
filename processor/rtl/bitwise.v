module bitwise (
    input [7:0] a,
    input [7:0] b,

    input [1:0] op_sel,

    input a_sel,
    input b_sel,

    output reg [7:0] res
);

wire real_a = (a_sel) ? b : a;
wire real_b = (b_sel) ? 8'hff : b;

always @(*) begin
    case (op_sel)
        2'b00: res <= real_a & real_b;
        2'b01: res <= real_a | real_b;
        default: res <= real_a ^ real_b;
    endcase
end

endmodule
