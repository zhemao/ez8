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

add wave cpu/mem_indir_addr
add wave cpu/indir_read_en
add wave -radix hexadecimal cpu/mc/indir_addr
add wave -radix hexadecimal cpu/operand
add wave -radix hexadecimal cpu/mem_readdata
add wave cpu/mem_write_en
add wave -radix hexadecimal cpu/mc/readaddr
add wave -radix hexadecimal cpu/mc/real_readaddr

run 6 us
