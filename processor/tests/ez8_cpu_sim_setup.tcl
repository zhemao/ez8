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
add wave cpu/pc_kill
add wave cpu/kill_write
add wave cpu/goto
add wave cpu/ret
add wave cpu/call
add wave cpu/skip

add wave cpu/retint
add wave cpu/interrupt
add wave cpu/pcc/interrupt_wait
add wave cpu/pcc/interrupt_save
add wave cpu/pcc/kill_shift
add wave cpu/save_accum
add wave -radix hexadecimal cpu/pcc/stack_output

set IgnoreSVAWarning 1

run 6 us
