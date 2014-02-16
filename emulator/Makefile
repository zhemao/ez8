CFLAGS=-Wall -g

ez8_emu: emulator.o ez8.o
	$(CC) $^ $(LDFLAGS) -o $@

emulator.o: emulator.c

ez8.o: ez8.c ez8.h

clean:
	rm -f *.o ez8_emu
