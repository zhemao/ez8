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

reg [3:0] key_reg;
reg [3:0] switch_reg;
reg [3:0] led_reg;

assign leds = led_reg;

reg [3:0] switches_flipped;

assign interrupts = {switches_flipped, ~key_reg};

always @(posedge clk) begin
    if (reset) begin
        key_reg <= 4'd0;
        switch_reg <= 4'd0;
        led_reg <= 4'd0;
        switches_flipped <= 4'd0;
    end else begin
        key_reg <= keys;
        switch_reg <= switches;
        switches_flipped <= switch_reg ^ switches;

        case (readaddr)
            5'd0: readdata <= {switch_reg, key_reg};
            5'd1: readdata <= {4'b0, leds};
            default: readdata <= 8'd0;
        endcase

        if (write_en) begin
            case (writeaddr)
                5'd1: led_reg <= writedata[3:0];
            endcase
        end
    end
end

endmodule
