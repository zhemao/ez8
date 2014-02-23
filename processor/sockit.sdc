create_clock -name master_clk -period 20 [get_ports {OSC_50_B3B}]
derive_pll_clocks
