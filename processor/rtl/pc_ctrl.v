module pc_ctrl (
    input clk,
    input reset,

    output [11:0] pc_out
);

reg [11:0] pc = 12'd0;
assign pc_out = pc;

always @(posedge clk) begin
    if (reset)
        pc <= 12'd0;
    else
        pc <= pc + 1'b1;
end

endmodule
