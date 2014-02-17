module addsub (
    input [7:0] a,
    input [7:0] b,
    input cin,
    input sub,
    input take_carry,
    output [7:0] sum,
    output cout
);

wire [7:0] real_b = (sub) ? ~b : b;
reg real_cin;

always @(*) begin
    if (sub)
        real_cin = 1'b1;
    else if (take_carry)
        real_cin = cin;
    else
        real_cin = 1'b0;
end

wire [8:0] big_sum = a + real_b + real_cin;

assign cout = big_sum[8];
assign sum = big_sum[7:0];

endmodule
