module skip_calc (
    input [3:0] opcode,
    input [7:0] reg_value,
    input [7:0] accum_value,
    input [2:0] selector,
    input direction,
    output reg skip
);

// the value we actually compare to depends on the direction
wire [7:0] used_value = (direction) ? reg_value : accum_value;

wire eqz = (used_value == 8'd0);
wire nez = !eqz;
// negative numbers have the MSB set
wire ltz = used_value[7];
// greater than is the same as not less than and not zero
wire gtz = !ltz && !eqz;
// less than or equal to: pretty self-explanatory
wire lez = ltz || eqz;
// greater than or equal to is the opposite of less than
wire gez = !ltz;

wire bs = used_value[selector];
wire bc = !bs;

always @(*) begin
    case (opcode)
        4'b1010: case (selector)
            3'b000:  skip = eqz; // skeqz
            3'b001:  skip = nez; // sknez
            3'b010:  skip = ltz; // skltz
            3'b011:  skip = gez; // skgez
            3'b100:  skip = gtz; // skgtz
            default: skip = lez; // sklez
        endcase
        // skbc
        4'b1011: skip = bs; // skbs
        4'b1100: skip = bc; // skbc
        default: skip = 1'b0;
    endcase
end

endmodule
