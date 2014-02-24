module pc_ctrl (
    input clk,
    input reset,
    input pause,

    input goto,
    input [11:0] goto_addr,
    input call,
    input skip,
    input ret,
    input interrupt,
    output reg save_accum,

    output reg error,
    output reg stopped,
    output [11:0] pc_out,
    output kill
);

parameter INTERRUPT_VECTOR = 12'd4;

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

reg interrupt_wait = 1'b0;
reg interrupt_save = 1'b0;
reg stop_wait = 1'b0;

always @(posedge clk) begin
    if (reset) begin
        error <= 1'b0;
        stopped <= 1'b0;
        kill_shift <= 2'b11;
        pc <= 12'd0;
        interrupt_wait <= 1'b0;
        interrupt_save <= 1'b0;
        save_accum <= 1'b0;
    end else if (!pause && !stopped) begin
        push <= 1'b0;
        pop <= 1'b0;
        save_accum <= 1'b0;

        if (interrupt_save) begin
            if (full) begin
                error <= 1'b1;
                stopped <= 1'b1;
            end else begin
                stack_input <= pc;
                push <= 1'b1;
            end
            pc <= INTERRUPT_VECTOR;
            interrupt_save <= 1'b0;
            kill_shift <= {kill_shift[0], 1'b1};
            save_accum <= 1'b1;
        end else if (interrupt_wait) begin
            if (skip && !kill_shift[1])
                pc <= pc + 1'b1;
            interrupt_wait <= 1'b0;
            interrupt_save <= 1'b1;
            kill_shift <= {kill_shift[0], 1'b1};
        end else if (skip && !kill_shift[1]) begin
            // pc is at the correct instruction,
            // but the last instruction was issued improperly
            // so send a kill signal to cancel
            if (interrupt) begin
                kill_shift <= 2'b11;
                interrupt_save <= 1'b1;
            end else begin
                kill_shift <= 2'b10;
                pc <= pc + 1'b1;
            end
        end else if (goto && !kill_shift[0]) begin
            if (call) begin
                if (full) begin
                    // stack overflow
                    error <= 1'b1;
                    stopped <= 1'b1;
                end else begin
                    // pc should currently be at
                    // call instruction's address + 1
                    stack_input <= pc;
                    push <= 1'b1;
                end
            end
            kill_shift <= {kill_shift[0], 1'b1};
            pc <= goto_addr;
            if (interrupt)
                interrupt_save <= 1'b1;
        end else if (ret && !kill_shift[0]) begin
            if (empty)
                // processor exited
                // wait a cycle for the instruction to go through
                stop_wait <= 1'b1;
            else begin
                pc <= stack_output;
                pop <= 1'b1;
                if (interrupt)
                    interrupt_save <= 1'b1;
            end
            kill_shift <= {kill_shift[0], 1'b1};
        end else if (stop_wait) begin
            stopped <= 1'b1;
            stop_wait <= 1'b0;
        end else begin
            if (interrupt) begin
                kill_shift <= {kill_shift[0], 1'b1};
                interrupt_wait <= 1'b1;
            end else begin
                kill_shift <= {kill_shift[0], 1'b0};
                pc <= pc + 1'b1;
            end
        end
    end
end

endmodule
