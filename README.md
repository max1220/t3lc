# t3lc

*Tiny Transport Triggered Logic CPU(t3lc)*

The t3lc is a simple transport-triggered CPU.
 * 8-bit instructions(4-bit source + 3-bit target or 7-bit immediate value)
 * 4 8-bit registers + 7-bit last immediate-value register
 * 8-bit bi-directional DATA bus
 * 8-bit ALU with 8-bit ACC register(15 ops + read ACC)
 * 256-byte stack
 * 2 peripheral write ports

![LogiSim circuit](doc/t3lc.svg)



## Implementation

The t3lc is implemented as a LogiSim evolution circuit, in the
file [t3lc.circ](t3lc.circ)

See [T3LC.md](doc/T3LC.md).



## Assembler

The assembler can compile assembly-like source files into machine code.

See [ASSEMBLER.md](doc/ASSEMBLER.md)



## Emulator

The emulator can run compiled t3lc programs.

See [EMULATOR.md](doc/EMULATOR.md)
