module pc_ctrl (
    input clk,
    input reset,
    input pause,

    input goto,
    input [11:0] goto_addr,
    input call,
    input skip,
    input ret,

    output reg error,
    output reg stopped,
    output [11:0] pc_out,
    output kill
);

reg [11:0] pc = 12'd0;
assign pc_out = pc;
reg [1:0] kill_shift;
assign kill = kill_shift[1];

reg push;
reg pop;
wire empty;
wire full;
reg [11:0] stack_input;
wire [11:0] stack_output;

stack s (
    .clk (clk),
    .reset (reset),
    .push (push),
    .pop (pop),
    .writedata (stack_input),
    .readdata (stack_output),
    .empty (empty),
    .full (full)
);

always @(posedge clk) begin
    if (reset) begin
        error <= 1'b0;
        stopped <= 1'b0;
        kill_shift <= 2'b11;
        pc <= 12'd0;
    end else if (!pause && !stopped) begin
        push <= 1'b0;
        pop <= 1'b0;
        if (skip && !kill_shift[1]) begin
            // pc is at the correct instruction,
            // but the last instruction was issued improperly
            // so send a kill signal to cancel
            kill_shift <= 2'b10;
            pc <= pc + 1'b1;
        end else if (goto && !kill_shift[0]) begin
            if (call) begin
                if (full) begin
                    // stack overflow
                    error <= 1'b0;
                    stopped <= 1'b1;
                end
                // pc should currently be at
                // call instruction's address + 1
                stack_input <= pc;
                push <= 1'b1;
            end
            kill_shift <= {kill_shift[0], 1'b1};
            pc <= goto_addr;
        end else if (ret && !kill_shift[1]) begin
            if (empty)
                // processor exited
                stopped <= 1'b1;
            else begin
                pc <= stack_output;
                pop <= 1'b1;
            end
        end else begin
            kill_shift <= {kill_shift[0], 1'b0};
            pc <= pc + 1'b1;
        end
    end
end

endmodule
