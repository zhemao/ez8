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

// this is the address the pc jumps to after an interrupt
parameter INTERRUPT_VECTOR = 12'd4;

reg [11:0] pc = 12'd0;
assign pc_out = pc;

// The kill signal is used to cancel an instruction that was mistakenly
// issued (i.e. a skipped instruction or instruction issued after a goto)
// it does this by disabling the write enables going to the memory controller.
// Since there are two pipeline stages between the pc stage and the write
// stage, we need a 2-deep shift register.
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

// After an interrupt, we need to wait at most two cycles for the
// instructions already in the pipeline (in the instruction decode and
// read/exec stage) to be committed
reg interrupt_wait = 1'b0;
reg interrupt_save = 1'b0;
reg stop_wait = 1'b0;

initial begin
    // make sure the reg outputs are set correctly in the beginning
    stopped = 1'b0;
    error = 1'b0;
end

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

        // we enter this state when we are ready to switch into the
        // interrupt context
        if (interrupt_save) begin
            // we can't safely enter the interrupt context if we can't
            // save the pc on the stack
            if (full) begin
                error <= 1'b1;
                stopped <= 1'b1;
            end else begin
                // program counter should have correct return address by now
                // see below for how this is handled
                stack_input <= pc;
                push <= 1'b1;
            end
            pc <= INTERRUPT_VECTOR;
            interrupt_save <= 1'b0;
            // we still need to kill the last instruction,
            // which will be the one at the return address
            kill_shift <= {kill_shift[0], 1'b1};
            save_accum <= 1'b1;
        end else if (interrupt_wait) begin
            // if the current pc was actually skipped
            // the return address should be the next one
            if (skip && !kill_shift[1])
                pc <= pc + 1'b1;
            // transition into interrupt_save
            interrupt_wait <= 1'b0;
            interrupt_save <= 1'b1;
            kill_shift <= {kill_shift[0], 1'b1};
        end else if (skip && !kill_shift[1]) begin
            // pc is at the correct instruction,
            // but the last instruction was issued improperly,
            // so send a kill signal to cancel
            if (interrupt) begin
                // If the instruction in read/exec during an interrupt
                // is a taken skip, we can go directly to interrupt_save,
                // since the instruction currently in decode will be skipped
                kill_shift <= 2'b11;
                interrupt_save <= 1'b1;
            end else begin
                kill_shift <= 2'b10;
                pc <= pc + 1'b1;
            end
        end else if (goto && !kill_shift[0]) begin
            // If this is a call, then we need to save the
            // address after that of the call instruction
            // on the stack.
            if (call) begin
                if (full) begin
                    // stack overflow
                    error <= 1'b1;
                    stopped <= 1'b1;
                end else begin
                    // pc should currently be at
                    // call instruction's address + 1
                    // since we are one cycle after issue
                    stack_input <= pc;
                    push <= 1'b1;
                end
            end
            // kill the last instruction since it was issued
            // by mistake
            kill_shift <= {kill_shift[0], 1'b1};
            pc <= goto_addr;
            // instruction currently in instruction decode is a goto or call
            // which doesn't write anything, so we can skip to interrupt_save
            if (interrupt)
                interrupt_save <= 1'b1;
        end else if (ret && !kill_shift[0]) begin
            // this is mostly the same as call,
            // except we pop the stack instead of pushing
            if (empty)
                // processor exited
                // wait a cycle for the last instruction to go through
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
            // if the instructions in the pipeline are not skips or gotos
            // we need to wait the full two cycles before switching
            // to the interrupt context
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
