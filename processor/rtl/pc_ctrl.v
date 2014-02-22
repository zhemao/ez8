module pc_ctrl (
    input clk,
    input reset,
    input pause,

    output [11:0] pc_out,
    output reg [2:0] kill
);

reg [11:0] pc = 12'd0;
assign pc_out = pc;

always @(posedge clk) begin
    if (reset) begin
        kill <= 3'b110;
        pc <= 12'd0;
    end else if (!pause) begin
        kill <= 3'b000;
        pc <= pc + 1'b1;
    end
end

endmodule
