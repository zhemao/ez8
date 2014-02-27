module switch_key_ctrl (
    input clk,
    input reset,

    input [3:0] keys,
    input [3:0] switches,
    output flipped,

    output [7:0] readdata
);

wire [7:0] switch_key = {switches, keys};
reg  [7:0] switch_key_reg;
reg  [7:0] switch_key_flipped;

assign readdata = switch_key_reg;

assign flipped = (switch_key_flipped != 8'd0);

always @(posedge clk) begin
    if (reset) begin
        switch_key_reg <= 8'h0f;
        switch_key_flipped <= 8'd0;
    end else begin
        switch_key_reg <= switch_key;
        switch_key_flipped <= switch_key_reg ^ switch_key;
    end
end

endmodule
