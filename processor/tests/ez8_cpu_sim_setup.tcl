add wave clk
add wave reset
add wave pause

add wave -radix hexadecimal cpu/pc
add wave -radix hexadecimal accum
add wave -radix hexadecimal cpu/instr

run 300 ns
