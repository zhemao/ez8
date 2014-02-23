add wave clk
add wave reset
add wave pause
add wave stopped
add wave {error}

add wave -radix hexadecimal cpu/pc
add wave -radix hexadecimal accum
add wave -radix hexadecimal cpu/instr
add wave cpu/pc_kill
add wave cpu/kill_write
add wave cpu/goto
add wave cpu/ret
add wave cpu/call

run 1200 ns
