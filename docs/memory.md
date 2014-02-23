# EZ8 Memory

The EZ8 processor's memory is composed of an 8-bit accumulator and a banked
SRAM with 8-bit words and an 8-bit address space.

## Memory Map

### 00 : Null Register

When read, always gives zero. Writing to this register does nothing.

### 01 : STATUS Register

The status register is divided into bits in the following manner.

 * Bit 7 - GIE
 * Bits 6:5 - Bank
 * Bit 1 - C
 * Bit 0 - Z

Setting the GIE bit enables interrupts. Clearing it disables interrupts.
The GIE bit is automatically cleared when an interrupt occurs.

The bank bits select the memory bank. This will be discussed in more detail
later.

The C bit is set if there is a carry out from the most significant bit during
an arithmetic instruction.

The Z bit is set if the result of an arithmetic or bitwise instruction is zero.

### 02 : INTCON Register

The EZ8 has 8 distinct interrupts. You can enable or disable each one by
setting or clearing the corresponding bit in this register.

### 03 : INTSTATUS Register

If one of the 8 interrupts occurs, the corresponding bit in this register will
be set.

### 08 - 0F : IO Memory

Reserved for Memory-Mapped I/O

### 10 - FF : General Purpose Memory

This is mapped to actual RAM.

## Banking

IO Memory and General-Purpose memory are separated into banks to allow
addressing of more memory than the 8-bit address would normally allow.
Set the bank bits in the STATUS register to switch banks.
