module pc_ctrl (
    input clk,
    input reset,
    input pause,

    input goto,
    input [11:0] goto_addr,

    output [11:0] pc_out,
    output kill
);

reg [11:0] pc = 12'd0;
assign pc_out = pc;
reg [1:0] kill_shift;
assign kill = kill_shift[1];

always @(posedge clk) begin
    if (reset) begin
        kill_shift <= 2'b11;
        pc <= 12'd0;
    end else if (!pause) begin
        if (goto) begin
            kill_shift <= {kill_shift[0], 1'b1};
            pc <= goto_addr;
        end else begin
            kill_shift <= {kill_shift[0], 1'b0};
            pc <= pc + 1'b1;
        end
    end
end

endmodule
