add wave clk
add wave -radix hexadecimal writeaddr
add wave -radix hexadecimal readaddr
add wave -radix unsigned writedata
add wave -radix unsigned readdata
add wave -radix unsigned accum_out
add wave accum_write
add wave write_en
add wave zin
add wave z_write
add wave cin
add wave c_write
add wave cout

add wave -radix unsigned mc/status

run 300 ns
