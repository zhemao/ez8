create_clock -name master_clk -period 20 [get_ports {OSC_50_B3B}]
set_input_delay -clock master_clk -min 2 [all_inputs]
set_input_delay -clock master_clk -max 3 [all_inputs]
set_output_delay -clock master_clk -min 2 [all_outputs]
set_output_delay -clock master_clk -max 3 [all_outputs]
derive_pll_clocks
