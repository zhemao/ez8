module stack (
    input clk,
    input reset,
    input push,
    input pop,
    input [11:0] writedata,

    output [11:0] readdata,
    output empty,
    output full
);

reg [11:0] stack_mem [0:14];
reg [3:0] tos = 4'hf;

assign empty = (tos == 4'hf);
assign full = (tos == 4'he);

assign readdata = (empty) ? 12'd0 : stack_mem[tos];

always @(posedge clk) begin
    if (reset)
        tos <= 4'hf;
    else if (push && pop)
        stack_mem[tos] <= writedata;
    else if (push) begin
        stack_mem[tos + 1'b1] <= writedata;
        tos <= tos + 1'b1;
    end else if (pop) begin
        tos <= tos - 1'b1;
    end
end

endmodule
