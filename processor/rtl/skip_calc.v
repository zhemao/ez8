module skip_calc (
    input [1:0] opcode,
    input [7:0] reg_value,
    input [7:0] accum_value,
    input [2:0] selector,
    input direction,
    output reg skip
);

wire [7:0] used_value = (direction) ? reg_value : accum_value;

wire eqz = (used_value == 8'd0);
wire nez = !eqz;
wire ltz = used_value[7];
wire gtz = !ltz && !eqz;
wire lez = ltz || eqz;
wire gez = !ltz;

wire bs = used_value[selector];
wire bc = !bs;

always @(*) begin
    case (opcode)
        2'b00: skip <= bc;
        2'b11: skip <= bs;
        default: case (selector)
            3'b000:  skip <= eqz;
            3'b001:  skip <= nez;
            3'b010:  skip <= ltz;
            3'b011:  skip <= gez;
            3'b100:  skip <= gtz;
            default: skip <= lez;
        endcase
    endcase
end

endmodule
