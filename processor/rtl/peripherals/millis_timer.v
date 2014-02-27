module millis_timer (
    input clk,
    input reset,

    input [7:0] count_in,
    input count_write,
    output [7:0] count_out,

    output reg expired
);

// 50000 cycles is 1 ms
parameter SHORT_COUNT_START = 16'd49999;

reg [7:0] long_count;
reg [15:0] short_count;
reg count_down = 1'b0;

assign count_out = long_count;

always @(posedge clk) begin
    if (reset) begin
        long_count <= 8'd0;
        short_count <= SHORT_COUNT_START;
        expired <= 1'b0;
        count_down <= 1'b0;
    end else if (count_write) begin
        long_count <= count_in;
        count_down <= 1'b1;
        expired <= 1'b0;
    end else if (count_down) begin
        if (short_count == 16'd0) begin
            short_count <= SHORT_COUNT_START;
            if (long_count != 8'd0)
                long_count <= long_count - 1'b1;
            else begin
                expired <= 1'b1;
                count_down <= 1'b0;
            end
        end else
            short_count <= short_count - 1'b1;
    end else
        expired <= 1'b0;
end

endmodule
