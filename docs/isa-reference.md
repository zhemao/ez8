# EZ8 Instruction Reference

## Direction Convention

Many instructions can be instructed to place the result in either the
accumulator or in a memory address. If the direction flag is set to 0,
the result will be placed in the accumulator. If the direction flag is set
to 1, the result will be placed in memory. In the assembler, you can use
the letters A (for accumulator) and M (for memory) as aliases for 0 and 1,
respectively.

## Instructions Operating on Memory

### Get

Syntax: `get a`

Encoding: 0000aaaaaaaa0000

Fetches the value at the given address from memory and puts it into the
accumulator register.

### Put

Syntax: `put a`

Encoding: 0000aaaaaaaa0001

Writes the value in the accumulator register to memory at the given address.

### Set

Syntax: `set L`

Encoding: 0100LLLLLLLL0000

Set the accumulator register to the literal value

### Clear

Syntax: `clr [a]`

Encoding: 1111aaaaaaaa0001 | 1111000000000000

If address is provided, set the value of the memory cell at that address to 0.
Otherwise, set the accumulator value to 0.

### Indirect Get

Syntax: `iget a`

Encoding: 1110aaaaaaaa0bb0

Indirect fetch into the accumulator. The indirect registers take up addresses
04 - 07 of virtual memory. This instruction will fetch the value at address
`indirects[b] + a` into the accumulator.

### Indirect Put

Syntax `iput a`

Encoding: 1110aaaaaaaa0bb1

Writes the accumulator value to address `indirects[b] + a` in memory.

## Shift Instructions

### Logical Shift Left

Syntax: `sll a [d]`

Encoding: 0001aaaaaaaa000d

Shift the accumulator value left by the value at the given address.

### Logical Shift Right

Syntax: `srl a [d]`

Encoding: 0001aaaaaaaa100d

Logically shift the accumulator value right by the value at the given address.

### Arithmetic Shift Right

Syntax: `sra a [d]`

Encoding: 0001aaaaaaaa110d

Arithmetically shift the accumulator value right by the value at the given address.

### Logical Shift Left Literal

Syntax: `slll L`

Encoding: 0101LLLLLLLL0000

Shift the accumulator value left by the literal value.

### Logical Shift Right Literal

Syntax: `srll L`

Encoding: 0101LLLLLLLL1000

Logically shift the accumulator value right by the literal value.

### Arithmetic Shift Right Literal

Syntax: `sral L`

Encoding: 0101LLLLLLLL1100

Arithmetically shift the accumulator value right by the literal value.

## Arithmetic Operations

### Add

Syntax: `add a [d]`

Encoding: 0010aaaaaaaa000d

Add the value at the given memory address with the accumulator value.

### Add with Carry

Syntax: `adc a [d]`

Encoding: 0010aaaaaaaa010d

Add the value at the given memory address with the accumulator value and
the carry flag.

### Subtract

Syntax: `sub a [d]`

Encoding: 0010aaaaaaaa100d

Subtract the value at the given memory address from the accumulator value.

### Add Literal

Syntax: `addl L`

Encoding: 0110LLLLLLLL0000

Add the literal value to the accumulator value.

### Add with Carry Literal

Syntax: `adcl L`

Encoding: 0110LLLLLLLL0100

Add the literal value and carry flag to the accumulator.

### Subtract Literal

Syntax: `subl L`

Encoding: 0110LLLLLLLL1000

Subtract the literal value from the accumulator.

## Bitwise Instructions

### Bitwise And

Syntax: `and a [d]`

Encoding: 0011aaaaaaaa000d

Bitwise AND of the value at the memory address and the accumulator.

### Bitwise Inclusive Or

Syntax: `ior a [d]`

Encoding: 0011aaaaaaaa010d

Bitwise OR of the value at the memory address and the accumulator.

### Bitwise Exclusive Or

Syntax: `xor a [d]`

Encoding: 0011aaaaaaaa100d

Bitwise XOR of the value at the memory address and the accumulator.

### Bitwise And Literal

Syntax: `andl L`

Encoding: 0111LLLLLLLL0000

Bitwise AND of the literal and the accumulator.

### Bitwise Inclusive Or Literal

Syntax: `iorl L`

Encoding: 0111LLLLLLLL0100

Bitwise OR of the literal and the accumulator.

### Bitwise Exclusive Or Literal

Syntax: `xorl L`

Encoding: 0111LLLLLLLL1000

Bitwise XOR of the literal and the accumulator.

### One's Complement

Syntax: `com [a]`

Encoding: 1111000000001000 | 1111aaaaaaaa1001

If address given, flip the bits at the given address. If no address given,
flip the bits in the accumulator.

## Unconditional Jump Instructions

### Goto

Syntax: `goto a`

Encoding: 1000aaaaaaaaaaaa

Set program counter to given address.

### Call

Syntax: `call a`

Encoding: 1001aaaaaaaaaaaa

Push the next instruction address onto the stack and set program counter to the
given address.

### Return

Syntax: `ret`

Encoding: 1101000000000000

Set the program counter to the value on the top of the stack and pop the stack.

### Return from Interrupt

Syntax: `retint`

Encoding: 1101000000001000

Sets the program counter to the value popped off the stack. Also restores
accumulator value saved on interrupt, clears the INTCON register, and sets GIE
bit in status register.

## Conditional Skip Instructions

### Skip If Zero

Syntax: `skeqz [a]`

Encoding: 1101000000000000 | 1101aaaaaaaa0001

If address given, skip next instruction if the memory at that address is zero.
If address not given, skip if accumulator value is zero.

### Skip If Not Zero

Syntax: `sknez [a]`

Encoding: 1101000000000010 | 1101aaaaaaaa0011

Skip if the memory value is not equal to zero.

### Skip If Less Than Zero

Syntax: `skltz [a]`

Encoding: 1101000000000100 | 1101aaaaaaaa0101

Skip if the memory value is less than zero.

### Skip If Greater Than Zero

Syntax: `skgtz [a]`

Encoding: 1101000000001000 | 1101aaaaaaaa1001

Skip if the memory value is greater than zero.

### Skip If Less Than or Equal to Zero

Syntax: `sklez [a]`

Encoding: 1101000000001010 | 1101aaaaaaaa1011

Skip if the memory value is less than or equal to zero.

### Skip If Greater Than or Equal to Zero

Syntax: `skgez [a]`

Encoding: 1101000000000110 | 1101aaaaaaaa0111

Skip if the memory value is greater than or equal to zero.
