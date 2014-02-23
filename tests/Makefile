all: arithmetic.hex skips.hex indirect.hex \
	arithmetic.bin skips.bin indirect.bin

test: test_arithmetic test_skips test_indirect

test_%: %.bin
	../emulator/ez8_emu $<

%.bin: %.asm
	../assembler/ez8asm $<

%.hex: %.bin
	srec_cat $< -binary -o $@ -intel

clean:
	rm -f *.bin *.hex
