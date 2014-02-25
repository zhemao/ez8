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
assign interrupts[7:1] = 7'd0;

always @(posedge clk) begin
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
            endcase
        end
    end
end

endmodule
