create_clock -period 80MHz -name {clk_80mhz} [get_ports {clk_a}]

derive_clock_uncertainty
derive_pll_clocks -use_tan_name
