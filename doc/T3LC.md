# t3lc

*Tiny Transport Triggered Logic CPU(t3lc)*

The t3lc is a simple transport-triggered CPU.
 * 8-bit instructions(4-bit source + 3-bit target or 7-bit immediate value)
 * 4 8-bit registers + 7-bit last immediate-value register
 * 8-bit bi-directional DATA bus
 * 8-bit ALU with 8-bit ACC register(15 ops + read ACC)
 * 256-byte stack
 * 2 peripheral write ports



## DATA Bus

Since this is a TTA-like design, the DATA bus is the key to understanding
the operation of the t3lc CPU.

Each clock cycle, the source and target connections to the DATA bus are
enabled/disabled according to the current instruction.

Only a single source and a single target can be enabled at a time.



### DATA bus sources

 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * TOS
 * ALU
 * REG_IMM
 * RAM_READ

Additionally, the values 0,1,2,4,8,16,32,18 can be directly configured
as a source on the DATA bus.

### DATA bus targets

 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * CNT_PC(*)
 * PUSH
 * CNT_SP
 * RAM_WRITE(*)

`(*)` The registers REG_I and REG_J form the address.

See below for a description of what each source/target does.
Some combinations of source and target have a special meaning:
`REG_A -> REG_A` is `HALT`
`REG_B -> REG_B` is `CLEAR_ACC`
`REG_I -> REG_I` is `PERI0_WRITE`
`REG_J -> REG_J` is `PERI1_WRITE`
`TOS -> CNT_PC` is `BRANCH`
`RAM -> RAM` is `POP`




## Registers

`REG_A`, `REG_B`, `REG_I`, `REG_J` can be configured as a
source or a target on the DATA bus

`REG_I` and `REG_J` form the RAM address when loading/storing,
and the PC value when jumping.

`REG_IMM` can only be configured as a source,
bits 0,1,2,3 set the ALU operation,
and when writing values consecutively the previous value
is pushed onto the stack.



## Program counter

The 16-bit program counter `CNT_PC` is automatically incremented every clock cycle,
and can be loaded from the registers `REG_I` and `REG_J`.
It determines the ROM address that is beeing read as an instruction.



## Stack

The t3lc CPU has a 256-byte general-purpose stack.
The 8-bit stack pointer `CNT_SP` is the current index into the stack and
can be loaded from the registers REG_I and REG_J.

It supports the following operations:
 * PUSH
   - copies the current value on the DATA bus to it's memory,
     then increments `CNT_SP`(stack is a target on the DATA bus).
 * POP
   - The stack pointer is decremented
 * TOS
   - provides the current value on top of the stack on the DATA bus
     (stack is a source on the DATA bus)
 * LOAD_SP
   - copies the current value on the DATA bus into CNT_PC
     (stack is a target on the DATA bus).

The stack can be also be PUSH'ed using successive writes to `REG_IMM`:
When a value is written to `REG_IMM`, and the previous instruction was
also a write to `REG_IMM`, then the current value of `REG_IMM` is pushed
to the stack before a new value is loaded. This makes the



## ROM

The 8-bit ROM is used exclusively to fetch instructions.

The 16-bit ROM address is provided by `CNT_PC`, which can be loaded
from the DATA bus or from REG_IMM for when branching.
The ROM can't be read directly, only via 7-bit immediate values.



## RAM

The 8-bit RAM can only be used to store or load data,
no execution of instructions from RAM is possible directly.

The 16-bit address is provided by the registers `REG_I` and `REG_J`.



## ALU

The 8-bit ALU can be configured to be a source on the DATA bus.
It provides the result of OP(REG_A, REG_B),
where OP is determined by bits 4,5,6 from REG_I.

| Bits | Name    | Result
| ---- | ------- | ------
| 0000 |     ADD | REG_A + REG_B
| 0001 |     SUB | REG_A - REG_B
| 0010 |     MUL | REG_A * REG_B
| 0011 |     SUB | !REG_A
| 0100 |     AND | REG_A << REG_B
| 0101 |      OR | REG_A * REG_B
| 0110 |     XOR | REG_A > REG_B
| 0111 |     NOT | REG_A == REG_B
| 1000 | LSHIFT1 | REG_A + REG_B
| 1001 |  LSHIFT | REG_A & REG_B
| 1010 | RSHIFT1 | REG_A | REG_B
| 1011 |  RSHIFT | !REG_A
| 1100 |     NEG | REG_A << REG_B
| 1101 |      GT | REG_A * REG_B
| 1110 |      EQ | REG_A > REG_B
| 1111 |     ACC | REG_A == REG_B


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
