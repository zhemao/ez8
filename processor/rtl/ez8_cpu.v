module ez8_cpu (
    input clk,
    input reset,
    input pause,

    input [11:0] instr_writeaddr,
    input [15:0] instr_writedata,
    input instr_write_en,

    output [7:0] io_writedata,
    output [4:0] io_writeaddr,
    output io_write_en,
    input  [7:0] io_readdata,
    output [4:0] io_readaddr,
    input  [7:0] io_interrupts,

    output stopped,
    output error,
    output [7:0] accum_out
);

wire [11:0] pc;
wire pc_kill;
wire pc_stopped;
wire kill_write = pc_kill || pause || pc_stopped;

assign stopped = pc_stopped;
wire running = !pause && !pc_stopped;

wire [11:0] goto_addr;
wire goto;
wire call;
wire skip;
wire ret;
wire save_accum;
wire interrupt;

pc_ctrl pcc (
    .clk (clk),
    .reset (reset),
    .pause (pause),

    .goto_addr (goto_addr),
    .goto (goto),
    .call (call),
    .skip (skip),
    .ret (ret),
    .interrupt (interrupt),
    .save_accum (save_accum),
    .error (error),
    .stopped (pc_stopped),

    .pc_out (pc),
    .kill (pc_kill)
);

wire [15:0] instr;
assign goto_addr = instr[11:0];
assign goto = (instr[15:13] == 3'b100);
assign call = (instr[15:12] == 4'b1001);
assign ret = (instr[15:12] == 4'b1101);

instr_mem im (
    .rdclock (clk),
    .wrclock (clk),
    .rdclocken (running),
    .rdaddress (pc),
    .q (instr),
    .wraddress (instr_writeaddr),
    .data (instr_writedata),
    .wren (instr_write_en)
);

wire z;
wire c_forward;
wire c_backward;
wire z_write;
wire c_write;

reg [3:0] opcode;
wire [7:0] operand;
reg [2:0] selector;
reg direction;

wire indir_read_en = (instr[15:12] == 4'b1110);

// Synchronize parts of the instruction for the alu.
// operand is synchronized inside the memory controller,
// so we don't need to handle it here
always @(posedge clk) begin
    opcode <= instr[15:12];
    selector <= instr[3:1];
    direction <= instr[0];
end

wire [7:0] mem_writedata;
wire mem_write_en;
wire [7:0] mem_readaddr = instr[11:4];
wire [7:0] mem_readdata;
wire accum_write;
wire [7:0] accum;
wire [1:0] mem_indir_addr = instr[2:1];

assign accum_out = accum;

wire retint;

mem_ctrl mc (
    .clk (clk),
    .reset (reset),
    .pause (!running),

    .zin (z),
    .z_write (z_write && !kill_write),
    .cin (c_backward),
    .c_write (c_write && !kill_write),
    .cout (c_forward),
    .retint (retint),
    .save_accum (save_accum),
    .interrupt (interrupt),

    .writeaddr (operand),
    .writedata (mem_writedata),
    .write_en (mem_write_en && !kill_write),
    .readaddr (mem_readaddr),
    .readdata (mem_readdata),

    .indir_addr_in (mem_indir_addr),
    .indir_read_en (indir_read_en),
    .readaddr_out (operand),

    .io_interrupts (io_interrupts),
    .io_writeaddr (io_writeaddr),
    .io_writedata (io_writedata),
    .io_write_en (io_write_en),
    .io_readaddr (io_readaddr),
    .io_readdata (io_readdata),

    .accum_write (accum_write && !kill_write),
    .accum_out (accum)
);

alu alu0 (
    .opcode (opcode),
    .operand (operand),
    .regvalue (mem_readdata),
    .accum (accum),
    .selector (selector),
    .direction (direction),
    .cin (c_forward),

    .result (mem_writedata),
    .accum_write (accum_write),
    .reg_write (mem_write_en),
    .z_write (z_write),
    .zout (z),
    .c_write (c_write),
    .cout (c_backward),
    .retint (retint),
    .skip (skip)
);

endmodule
