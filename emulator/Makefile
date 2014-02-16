CFLAGS=-Wall -g

ez8_emu: emulator.o ez8.o
	$(CC) $^ $(LDFLAGS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $<
