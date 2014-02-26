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

reg [3:0] led_reg;

wire [7:0] switch_key = {switches, keys};
reg  [7:0] switch_key_reg;
reg  [7:0] switch_key_flipped;

assign leds = led_reg;

assign interrupts[0] = (switch_key_flipped != 8'd0);
assign interrupts[7:2] = 6'd0;

reg [7:0] timer_count;
reg timer_count_write;

millis_timer timer (
    .clk (clk),
    .reset (reset),
    .count_in (timer_count),
    .count_write (timer_count_write),
    .expired (interrupts[1])
);

always @(posedge clk) begin
    timer_count_write <= 1'b0;

    if (reset) begin
        switch_key_reg <= 8'd0;
        led_reg <= 4'd0;
        switch_key_flipped <= 8'd0;
    end else begin
        switch_key_reg <= switch_key;
        switch_key_flipped <= switch_key_reg ^ switch_key;

        case (readaddr)
            5'd0: readdata <= switch_key_reg;
            5'd1: readdata <= {4'b0, leds};
            default: readdata <= 8'd0;
        endcase

        if (write_en) begin
            case (writeaddr)
                5'd1: led_reg <= writedata[3:0];
                5'd2: begin
                    timer_count <= writedata;
                    timer_count_write <= 1'b1;
                end
            endcase
        end
    end
end

endmodule
