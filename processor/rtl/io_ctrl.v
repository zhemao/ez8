module io_ctrl (
    input clk,
    input reset,

    input  [4:0] readaddr,
    output reg [7:0] readdata,
    input  [4:0] writeaddr,
    input  [7:0] writedata,
    input  write_en,

    input  [3:0] keys,
    input  [3:0] switches,
    output [3:0] leds
);

reg [7:0] key_switch_reg;
reg [3:0] led_reg;

assign leds = led_reg;

always @(posedge clk) begin
    if (reset) begin
        key_switch_reg <= 8'd0;
        led_reg <= 4'd0;
    end else begin
        key_switch_reg <= {switches, keys};

        case (readaddr)
            5'd0: readdata <= key_switch_reg;
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
