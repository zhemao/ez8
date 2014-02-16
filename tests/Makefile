test: test_arithmetic

test_%: %.bin
	../emulator/ez8_emu $<

%.bin: %.asm
	../assembler/ez8asm $<
