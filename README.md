# t3lc

*Tiny Transport Triggered Logic CPU(t3lc)*

The t3lc is a simple transport-triggered CPU,
with an 8-bit `DATA` bus.

It comes in 3 variants.

For a more detailed description, see [T3LC.md](doc/T3LC.md).

## t3lc_mini

 - read/write bus are two instructions
 - 6 8-bit registers(3 general-purpose, 3 special)
 - 256bytes of ROM
 - 256bytes of RAM
 - 8-bit ALU



## t3lc_medium

 - read/write are one instruction
 - 4 register files(768-byte register memory)
 - 256-byte stack
 - 16K of ROM
 - 16K of RAM
 - 8-bit ALU

## t3lc_huge

 - read/write are two instructions
 - 4 register files(1024-byte register memory)
 - two 256-byte stacks
 - 8-bit ALU and 16-bit ALUs
 - 16M of IROM
 - 16M of DROM
 - 16M of RAM
 - 3 peripheral ports(could be used as 3*16M RAM)



## WIP Warning

Currently this project moves quickly and breaks a lot.
Documentation might not always be up-to-date.



## Implementation

The t3lc is implemented as a LogiSim evolution circuit, in the
file [t3lc.circ](t3lc.circ)

See [T3LC.md](doc/T3LC.md).



## Assembler

The assembler can compile assembly-like source files into machine code.

See [ASSEMBLER.md](doc/ASSEMBLER.md)



## Emulator

The emulator can run compiled t3lc programs(ROM images).

See [EMULATOR.md](doc/EMULATOR.md)
