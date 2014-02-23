# EZ8 : The easy 8-bit processor

This is an attempt to craft an 8-bit microcontroller architecture that is
easy to implement. Care is taken to choose the instruction encoding so that
instructions that perform similar tasks have similar encodings.

This repository contains an assembler written in OCaml, an emulator written in
C, some test assembly programs, and a three-stage pipelined processor written
in Verilog.

## Instructions for Verification

To verify that the processor is functioning correctly. Perform the following
steps.

1. Go into the "assembler" directory and run `make` to build the assembler.
   You will need to have an OCaml compiler installed.
2. Go into the "tests" directory and run `make` to assemble the test programs
   into machine code.
3. Open the "processor/ez8cpu.qpf" project in Quartus,
   run "Analysis and Synthesis", then run RTL simulation.
