module mem_ctrl (
    input clk,
    input reset,
    input pause,

    input zin,
    input z_write,
    input cin,
    input c_write,
    output cout,

    input [7:0] writeaddr,
    input [7:0] writedata,
    input write_en,

    input [7:0] readaddr,
    output reg [7:0] readdata,

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

assign accum_out = accum;
assign cout = status[1];

wire [1:0] bank = (writeaddr == 8'h01 && write_en) ?
                    writedata[6:5] : status[6:5];
reg [1:0] bank_sync;

always @(posedge clk) begin
    if (!pause) begin
        writeaddr_sync <= writeaddr;
        readaddr_sync <= readaddr;
        writedata_sync <= writedata;
        write_en_sync <= write_en;
        bank_sync <= bank;
    end
end

wire [7:0] gp_outputs [0:NUM_BANKS-1];

genvar i;
generate
for (i = 0; i < NUM_BANKS; i = i + 1) begin : MEM
    wire gp_wren = write_en && bank == i && writeaddr[7:4] != 4'd0;
    wire [7:0] gp_rdaddr = readaddr - 8'h10;
    wire [7:0] gp_wraddr = writeaddr - 8'h10;
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

always @(*) begin
    if (readaddr_sync == writeaddr_sync && write_en_sync)
        readdata <= writedata_sync;
    else if (readaddr_sync == 0)
        readdata <= 8'd0;
    else if (readaddr_sync == 8'd1)
        readdata <= status;
    else if (readaddr_sync == 8'd2)
        readdata <= intcon;
    else if (readaddr_sync == 8'd3)
        readdata <= intstatus;
    else if (readaddr_sync[7:2] == 6'd1)
        readdata <= indirects[readaddr_sync[1:0]];
    // IOMEM not implemented yet
    else if (readaddr_sync[7:3] == 5'd1)
        readdata <= 8'd0;
    else
        readdata <= gp_outputs[bank_sync];
end

always @(posedge clk) begin
    if (reset)
        accum <= 8'h00;
    else if (accum_write)
        accum <= writedata;

    if (write_en) begin
        if (writeaddr == 8'd1)
            status <= writedata;
        else if (writeaddr == 8'd2)
            intcon <= writedata;
        else if (writeaddr == 8'd3)
            intstatus <= writedata;
        else if (writeaddr[7:2] == 6'd1)
            indirects[writeaddr[1:0]] <= writedata;
    end

    if (!(write_en && writeaddr == 8'd1)) begin
        if (z_write)
            status[0] <= zin;
        if (c_write)
            status[1] <= cin;
    end
end

endmodule
