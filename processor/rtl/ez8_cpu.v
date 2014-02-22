module ez8_cpu (
    input clk,
    input reset,

    input [11:0] instr_writeaddr,
    input [15:0] instr_writedata,
    input instr_write_en,

    output [7:0] accum_out
);

wire [11:0] pc;

pc_ctrl pcc (
    .clk (clk),
    .reset (reset),
    .pc_out (pc)
);

wire [15:0] instr;

instr_mem im (
    .clock (clk),
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
reg [7:0] operand;
reg [2:0] selector;
reg direction;

always @(posedge clk) begin
    opcode <= instr[15:12];
    operand <= instr[11:4];
    selector <= instr[3:1];
    direction <= instr[0];
end

wire [7:0] mem_writedata;
wire mem_write_en;
wire [7:0] mem_readaddr = instr[11:4];
wire [7:0] mem_readdata;
wire accum_write;
wire [7:0] accum;

assign accum_out = accum;

mem_ctrl mc (
    .clk (clk),
    .reset (reset),
    .zin (z),
    .z_write (z_write),
    .cin (c_backward),
    .c_write (c_write),
    .cout (c_forward),

    .writeaddr (operand),
    .writedata (mem_writedata),
    .write_en (mem_write_en),

    .readaddr (mem_readaddr),
    .readdata (mem_readdata),

    .accum_write (accum_write),
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
    .cout (c_backward)
);

endmodule
