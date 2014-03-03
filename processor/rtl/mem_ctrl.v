module mem_ctrl (
    input clk,
    input reset,
    input pause,

    input zin,
    input z_write,
    input cin,
    input c_write,
    output cout,
    input retint,

    input [7:0] writeaddr,
    input [7:0] writedata,
    input write_en,

    input [7:0] readaddr,
    output reg [7:0] readdata,

    input  [7:0] io_interrupts,
    output [4:0] io_readaddr,
    input  [7:0] io_readdata,
    output [4:0] io_writeaddr,
    output [7:0] io_writedata,
    output io_write_en,

    input  [1:0] indir_addr_in,
    input indir_read_en,
    output [7:0] readaddr_out,

    output interrupt,
    input  save_accum,

    input accum_write,
    output [7:0] accum_out
);

parameter NUM_BANKS = 4;

reg [7:0] writeaddr_sync;
reg [7:0] readaddr_sync;
reg [7:0] writedata_sync;
reg write_en_sync;

reg [7:0] status = 8'd0;
reg [7:0] intcon = 8'd0;
reg [7:0] intstatus = 8'd0;
reg [7:0] indirects [0:3];
reg [7:0] accum = 8'd0;
reg [7:0] accum_backup;

assign accum_out = accum;
assign cout = status[1];

wire [1:0] bank = (writeaddr == 8'h01 && write_en) ?
                    writedata[6:5] : status[6:5];
reg [1:0] bank_sync;

reg  [7:0] indir_value;
wire [7:0] indir_addr = indir_value + readaddr;

// if the indirect register is being written to, we have to bypass
always @(*) begin
    if (writeaddr == {6'd1, indir_addr_in} && write_en)
        indir_value = writedata;
    else
        indir_value = indirects[indir_addr_in];
end

reg [7:0] real_readaddr;

// mux the actual read address
always @(*) begin
    if (indir_read_en)
        real_readaddr = indir_addr;
    else
        real_readaddr = readaddr;
end

// create registered versions of all the inputs to match with the
// gpmem registers
always @(posedge clk) begin
    if (!pause) begin
        writeaddr_sync <= writeaddr;
        readaddr_sync <= real_readaddr;
        writedata_sync <= writedata;
        write_en_sync <= write_en;
        bank_sync <= bank;
    end
end

assign readaddr_out = readaddr_sync;

// generate the io_* signals
// address is 2 bits of bank + lower 3 bits of address
assign io_readaddr = {bank, real_readaddr[2:0]};
assign io_writeaddr = {bank, writeaddr[2:0]};
assign io_writedata = writedata;
assign io_write_en = (writeaddr[7:3] == 5'd1) && write_en;

wire [7:0] gp_outputs [0:NUM_BANKS-1];

// generate statement for the general purpose memories
// create 1 per bank
genvar i;
generate
for (i = 0; i < NUM_BANKS; i = i + 1) begin : MEM
    // are we in the general purpose memory section?
    wire write_gp_section = writeaddr[7:4] != 4'd0;
    wire read_gp_section = real_readaddr[7:4] != 4'd0;

    // don't enable write if we are in the wrong section or bank
    wire gp_wren = write_en && bank == i && write_gp_section;
    wire [7:0] gp_rdaddr = (!read_gp_section) ? 8'd0 : real_readaddr - 8'h10;
    wire [7:0] gp_wraddr = (!write_gp_section) ? 8'd0 : writeaddr - 8'h10;

    gpmem mem (
        .clock (clk),
        .data (writedata),
        .rdaddress (gp_rdaddr),
        .wraddress (gp_wraddr),
        .wren (gp_wren),
        .q (gp_outputs[i]),
        .enable (!pause)
    );
end
endgenerate

// mux readdata from the correct memory section
always @(*) begin
    // bypass if writing to the same address as read
    if (readaddr_sync == writeaddr_sync && write_en_sync)
        readdata = writedata_sync;
    // null register always returns 0
    else if (readaddr_sync == 0)
        readdata = 8'd0;
    else if (readaddr_sync == 8'd1)
        readdata = status;
    else if (readaddr_sync == 8'd2)
        readdata = intcon;
    else if (readaddr_sync == 8'd3)
        readdata = intstatus;
    else if (readaddr_sync[7:2] == 6'd1)
        readdata = indirects[readaddr_sync[1:0]];
    else if (readaddr_sync[7:3] == 5'd1)
        readdata = io_readdata;
    else
        readdata = gp_outputs[bank_sync];
end

// interrupt if GIE is set, one of the interrupts is triggered,
// and the triggered interrupt is enabled in intcon
wire internal_interrupt = status[7] && ((intcon & io_interrupts) != 0);
assign interrupt = internal_interrupt;

parameter STATUS_ADDR = 8'd1;
parameter INTCON_ADDR = 8'd2;
parameter INTSTATUS_ADDR = 8'd3;

always @(posedge clk) begin
    if (reset) begin
        accum <= 8'h00;
        status <= 8'h00;
        intcon <= 8'h00;
        intstatus <= 8'h00;
    end else begin
        // save_accum gets asserted by the PC controller
        // before switching into the interrupt context
        if (save_accum)
            accum_backup <= accum;
        if (accum_write)
            accum <= writedata;

        if (write_en) begin
            if (writeaddr == STATUS_ADDR)
                status <= writedata;
            else if (writeaddr == INTCON_ADDR)
                intcon <= writedata;
            else if (writeaddr == INTSTATUS_ADDR)
                intstatus <= writedata;
            else if (writeaddr[7:2] == 6'd1)
                indirects[writeaddr[1:0]] <= writedata;
            // don't need gpmem here, since that was taken care of
            // inside the for-generate statement
        end

        // only modify individual bits in the status register
        // if we are not already writing to the status register
        if (!(write_en && writeaddr == 8'd1)) begin
            if (z_write)
                status[0] <= zin;
            if (c_write)
                status[1] <= cin;
            if (retint) begin
                // on retint, set GIE again, restore the accumulator,
                // and clear intstatus so that it doesn't get confused
                // on the next interrupt
                status[7] <= 1'b1;
                accum <= accum_backup;
                intstatus <= 8'd0;
            end
        end

        if (internal_interrupt) begin
            // if an interrupt occurs, we need to clear GIE to disable
            // further interrupts and save which interrupts are set
            // into instatus
            status[7] <= 1'b0;
            intstatus <= io_interrupts;
        end
    end
end

endmodule
