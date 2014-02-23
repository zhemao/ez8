all: arithmetic.hex skips.hex indirect.hex

test: test_arithmetic test_skips test_indirect

test_%: %.bin
	../emulator/ez8_emu $<

%.bin: %.asm
	../assembler/ez8asm $<

%.hex: %.bin
	srec_cat $< -binary -o $@ -intel
