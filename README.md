# EZ8 : The easy 8-bit processor

This is an attempt to craft an 8-bit microcontroller architecture that is
easy to implement. Care is taken to choose the instruction encoding so that
instructions that perform similar tasks have similar encodings.

This repository contains an assembler written in OCaml, an emulator written in
C, some test assembly programs, and a three-stage pipelined processor written
in Verilog.

The RTL description is designed to be used on the Arrow SoCKit. You may be
able to port it to other Cyclone V-based boards, such as the DE1-SoC board,
but you will have to change the pin assignments in the settings file.

## Instructions for Verification

To verify that the processor is functioning correctly. Perform the following
steps.

1. Go into the "assembler" directory and run `make` to build the assembler.
   You will need to have an OCaml compiler installed.
2. Go into the "tests" directory and run `make` to assemble the test programs
   into machine code.
3. Open the "processor/ez8cpu.qpf" project in Quartus,
   run "Analysis and Synthesis", then run RTL simulation.

## Instructions for Running on FPGA

1. Build the assembler as above.
2. Go into the "tests" directory and run `make fpga` to build the
   FPGA test program. You will need to have [SRecord](http://srecord.sourceforge.net/)
   installed in order to do this.
3. Copy the "led\_example.hex" file to "processor/program.hex".
4. Open the project file in Quartus, run the Assembler, then open the
   programmer and program the FPGA through the USB Blaster.
5. The program should now be running. If switch 0 is off (down), the LEDs will
   sweep back and forth regularly. If switch 0 is on (up), the LEDs will
   advance when you press key 0.

Detailed documentation is available in the "docs/" folder.
