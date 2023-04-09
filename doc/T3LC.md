# t3lc

*Tiny Transport Triggered Logic CPU(t3lc)*



## Specs

The t3lc is a simple 8/16-bit CPU.
 * 5 8-bit registers(REG_A, REG_B, REG_I, REG_J, REG_IMM)
 * single 8-bit bi-directional bus called DATA.
 * up to 64K of ROM(16-bit address)
 * up to 64K of RAM(16-bit address)

The version described in this document is implemented
as a LogiSim-evolution circuit in the file t3lc.circ.



## Registers(REG_A, REG_B, REG_I, REG_J, REG_IMM)

All registers are 8-bit.

The registers REG_A, REG_B, REG_I, REG_J can be
loaded from or stored to via the DATA bus.

The registers REG_I, REG_J form the RAM address,
and the address loaded into PC to form the ROM address.

Bits 4,5,6 from REG_I are also used to form op-code for the ALU.

The special register REG_IMM can only
store a 7-bit value directly from an op-code.


## Program counter(CNT_PC)

The 16-bit program counter is automatically incremented every clock cycle.
It's output is used as the ROM address.

It can load a value from the registers REG_I and REG_J.



## DATA Bus

Each clock cycle, the connections to the DATA bus are re-configured
according to the current instruction from ROM.

Only a single source and a single target can be enabled at a time.

DATA bus sources:

 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * POP
 * TOS
 * ALU
 * RAM
 * REG_IMM
 * IMM_0
 * IMM_1
 * IMM_2
 * IMM_4
 * IMM_8
 * IMM_16
 * IMM_128

DATA bus targets:
 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * PC*
 * PUSH
 * SP
 * RAM*

`*` These values use the registers REG_I and REG_J to form an address.



### Memory

There are two types of memory: ROM and RAM.
All memory is byte-based and accessed using a 16-bit address.

The address for the ROM is the output of CNT_PC, and can be loaded
from the registers REG_I, REG_J.

The address for the RAM is the output of the registers REG_I and REG_J.

This way, the t3lc can address up to 64K of ROM and RAM.



### Stack

A stack is provided on the DATA bus. The stack size is 256 bytes.
The stack has the following functions:

 * push
   - read the value on the DATA bus, increment SP
 * pop
   - write TOS on the DATA bus, decrement SP
 * write_sp
   - Copy the value on the DATA bus to SP
 * tos
   - write TOS on the DATA bus



### ALU

The 8-bit ALU can be configured to be a source on the DATA bus.
It provides the result of OP(REG_A, REG_B),
where OP is determined by bits 4,5,6 from REG_I.

| Bits | Result
| ---- | -----
|  000 | REG_A + REG_B
|  001 | REG_A & REG_B
|  010 | REG_A | REG_B
|  011 | !REG_A
|  100 | REG_A << REG_B
|  101 | REG_A * REG_B
|  110 | REG_A > REG_B
|  111 | REG_A == REG_B



### Instructions

The instructions are best understood as configuring the DATA bus.

Each instruction is 8 bits.

The first 4 bits(bits 0-3) determine the target of the DATA bus:

| Bits | Name
| ---- | -----
| 0000 | REG_A
| 0001 | REG_B
| 0010 | REG_I
| 0011 | REG_J
| 0100 | POP
| 0101 | TOS
| 0110 | ALU
| 0111 | RAM
| 1000 | REG_IMM
| 1001 | IMM_0
| 1010 | IMM_1
| 1011 | IMM_2
| 1100 | IMM_4
| 1101 | IMM_8
| 1110 | IMM_16
| 1111 | IMM_128

The next 3 bits(bits 4-6) determine the source of the DATA bus:

| Bits | Name
| ---- | -----
|  000 | REG_A
|  001 | REG_B
|  010 | REG_I
|  011 | REG_J
|  100 | PC
|  101 | PUSH
|  110 | SP
|  111 | RAM


The last bit(bit 7) is special:

If set, the DATA bus is not used.
Instead, the lower 6 bits are loaded into the REG_IMM register.
