# assembler.lua

*Simple, extendable Lua DSL for translating assembly to machine code.*

This file implements a minimal generic assembler.
It uses Lua as a DSL(Domain-specific language) and is easily extendable.



## Usage

You can pass this tool any number of Lua source files.
These files are loaded by `dofile()`, and have some helper functions
available: `add_rokens_from_str(str), pop(), push(v), output(n)`

```
./assembler.lua asm/lib/encode8_hex.lua asm/hello.asm.lua > hello.hex
```



## Example

test.asm.lua:
```
-- IMM_REG loads immediate value 0x55
_ "IMM_REG 0x55"
-- Wr
_ "MOV IMM_REG PUSH"
```

```
$ ./assembler.lua test.asm.lua

```
