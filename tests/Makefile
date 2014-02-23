all: arithmetic.bin skips.bin indirect.bin banks.bin

test: test_arithmetic test_skips test_indirect test_banks

test_%: %.bin
	../emulator/ez8_emu $<

%.bin: %.asm
	../assembler/ez8asm $<

%.hex: %.bin
	srec_cat $< -binary -o $@ -intel

clean:
	rm -f *.bin *.hex
