add wave clk
add wave reset
add wave pause
add wave stopped
add wave {error}
add wave keys

add wave -radix unsigned instr_writeaddr
add wave -radix hexadecimal instr_writedata

add wave -radix unsigned cpu/pc
add wave -radix decimal accum
add wave -radix hexadecimal cpu/instr
add wave -radix hexadecimal cpu/opcode

run 6 us
