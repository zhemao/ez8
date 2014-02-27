module led_ctrl (
    input clk,
    input reset,

    output [3:0] leds,
    input  [7:0] writedata,
    output [7:0] readdata,
    input  write_en
);

reg [3:0] led_reg;

assign leds = led_reg;
assign readdata = {4'd0, led_reg};

always @(posedge clk) begin
    if (reset)
        led_reg <= 4'd0;
    else if (write_en)
        led_reg <= writedata[3:0];
end

endmodule
