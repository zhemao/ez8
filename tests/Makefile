test: test_arithmetic test_skips test_indirect

test_%: %.bin
	../emulator/ez8_emu $<

%.bin: %.asm
	../assembler/ez8asm $<
