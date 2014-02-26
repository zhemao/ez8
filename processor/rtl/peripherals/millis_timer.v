module millis_timer (
    input clk,
    input reset,

    input [7:0] count_in,
    input count_write,

    output expired
);

// 50000 cycles is 1 ms
parameter SHORT_COUNT_START = 16'd49999;

reg [7:0] long_count;
reg [15:0] short_count;

assign expired = (long_count == 8'd0);

always @(posedge clk) begin
    if (reset) begin
        long_count <= 8'd0;
        short_count <= SHORT_COUNT_START;
    end else if (count_write)
        long_count <= count_in;
    else begin
        if (short_count == 16'd0) begin
            short_count <= SHORT_COUNT_START;
            if (long_count != 8'd0)
                long_count <= long_count - 1'b1;
        end else
            short_count <= short_count - 1'b1;
    end
end

endmodule
