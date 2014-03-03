// This module handles access to IO memory.
// Make changes here if you want to add new peripherals

module io_ctrl (
    input clk,
    input reset,

    input  [4:0] readaddr,
    output reg [7:0] readdata,
    input  [4:0] writeaddr,
    input  [7:0] writedata,
    input  write_en,

    output [7:0] interrupts,

    input  [3:0] keys,
    input  [3:0] switches,
    output [3:0] leds
);

assign interrupts[7:2] = 6'd0;

wire timer_count_write = write_en && (writeaddr == 8'd2);
wire [7:0] timer_count;

millis_timer timer (
    .clk (clk),
    .reset (reset),
    .count_in (writedata),
    .count_out (timer_count),
    .count_write (timer_count_write),
    .expired (interrupts[1])
);

wire [7:0] sw_key_readdata;

switch_key_ctrl sw_key (
    .clk (clk),
    .reset (reset),

    .keys (keys),
    .switches (switches),
    .flipped (interrupts[0]),

    .readdata (sw_key_readdata)
);

wire [7:0] led_readdata;
wire led_write_en = write_en && (writeaddr == 8'd1);

led_ctrl led (
    .clk (clk),
    .reset (reset),
    .leds (leds),
    .writedata (writedata),
    .readdata (led_readdata),
    .write_en (led_write_en)
);

reg [7:0] readaddr_sync;

always @(posedge clk)
    readaddr_sync <= readaddr;

always @(*) begin
    case (readaddr_sync)
        8'd0: readdata = sw_key_readdata;
        8'd1: readdata = led_readdata;
        8'd2: readdata = timer_count;
        default: readdata = 8'd0;
    endcase
end

endmodule
