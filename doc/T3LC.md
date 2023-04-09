# t3lc

*Tiny Transport Triggered Logic CPU(t3lc)*



## Specs

The t3lc is a simple 8/16-bit CPU.
 * 4 8-bit registers(REG_A, REG_B, REG_I, REG_J)
 * 16-bit program counter(PC)
 * 16-bit counter for accessing DROM
 * bi-directional 8-bit bus called DATA.
 * uni-directional 16-bit bus called ADDR.
  - BUS always has value of REG_I and REG_J
 * up to 128K bytes of ROM
  - 64K IROM
  - 64K DROM
 * up to 128K bytes of RAM
  - 64K RAM0
  - 64K RAM1

The version described in this document is implemented
as a LogiSim-evolution circuit in the file t3lc.circ.



## Registers(REG_A, REG_B, REG_I, REG_J)

All registers are 8-bit, and can be loaded from or stored to via the
DATA bus.

 * REG_A
  - first operand in ALU
 * REG_B
  - second operand in ALU
 * REG_I
  - source on ADDR bus(lower byte)
 * REG_J
  - source on ADDR bus(higher byte)
  - upper 3 bits are ALU operation



## Program counter(CNT_PC)

 * 16-bit program counter
 * points to memory in IROM
 * loaded from ADDR bus



## DROM counter(CNT_DROM)

 * 16-bit DROM address
 * points to memory in DROM
 * auto-incremented on DROM read
 * loaded from ADDR bus



## DATA Bus

Each clock cycle, the connections to the DATA bus are re-configured
according to an instruction fetched from IROM.
Only a single source and a single target can be enabled at a time.

DATA bus sources:
 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * ALU
 * DROM
 * RAM0_READ
 * RAM1_READ

DATA bus targets:
 * REG_A
 * REG_B
 * REG_I
 * REG_J
 * (CNT_PC`*`)
 * (CNT_DROM`*`)
 * RAM0_WRITE
 * RAM1_WRITE

`*` These values actually ignore the value on the DATA bus, and use the
value on the ADDR bus(see below).


## ADDR Bus


### Memory

There are 3 types of memory: IROM, DROM, and RAM.
All memory is byte-based and accessed using a 16-bit address from the ADDR bus(REG_I and REG_J).
 - IROM can only be loaded as an instruction(execute-only),
 - DROM can be a source on the DATA bus(read-only)
 - RAM can be a source or a target on the DATA bus(read-write)

When an op-code reads from RAM:
 - RAM0_READ or RAM1_READ is raised
 - RAM0 or RAM1 becomes a source on the DATA bus,
   providing the value of the RAM at the address on the ADDR bus
 - CPU performs operation on value on DATA bus(e.g. store in register)

When an op-code writes to RAM:
 - CPU becomes source on the DATA bus,
   providing the value to write to the RAM
 - RAM0_WRITE or RAM1_WRITE is raised
 - RAM writes the value on the DATA bus at the address on the ADDR bus



### ALU

The 8-bit ALU can be configured to be a source on the DATA bus.
It provides the result of OP(REG_A, REG_B),
where OP is is determined by the highest 3 bits on the ADDR bus.

```
OP=000: REG_A + REG_B
OP=001: REG_A & REG_B
OP=010: REG_A | REG_B
OP=011: !REG_A
OP=100: REG_A << REG_B
OP=101: REG_A > REG_B
OP=110: REG_A == REG_B
OP=111: 0
```



### Instructions

The supported instructions are best understood as configuring the
DATA bus.
Each 8-bit instruction is split into two nibbles:
The lower nibble configures the source of the DATA bus,
and the higher nibble configures the target of the DATA bus.

| Bit  | Name
| ---- | -----
|    0 | READ_SEL0
|    1 | READ_SEL1
|    2 | READ_SEL2

| Bit  | Name
| ---- | -----
|    4 | WRITE_SEL0
|    5 | WRITE_SEL1
|    6 | WRITE_SEL2

