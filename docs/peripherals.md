# EZ8 Hardware Peripherals

The peripheral hardware for the EZ8 is defined in the "io\_ctrl" verilog
module and the modules in the "peripherals" directory. You can add your own
FPGA peripherals to the CPU by modifying "io\_ctrl.v". If your peripheral use
any of the top-level FPGA inputs, you will have to define them in "sockit\_top.v"
and pass them in through the port-mapping. The following documents the default
peripheral configuration.

## Keys and Switches

 * Address: 0x08
 * Bank: 0
 * Interrupt: 0

Bits 0 to 3 correspond to keys 0 to 3 (remember that the keys are active low).
Bits 4 to 7 correspond to switches 0 to 3. The interrupt is triggered whenever
the state of any of the keys or switches changes.

## LEDs

 * Address: 0x09
 * Bank: 0

Writing to this register sets the LEDs. Only bits 0 to 3 of the register are
used, corresponding to LED 0 to 3.

## Timer

 * Address: 0x0a
 * Bank: 0
 * Interrupt: 1

This is a millisecond timer. If the register is set to anything other than 0,
the value will be decremented every millisecond. The interrupt will be
triggered once the value reaches 0.
