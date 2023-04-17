# assembler.lua

*Simple, extendable Lua DSL for translating assembly to machine code.*

This file implements a minimal generic assembler.
It uses Lua as a DSL(Domain-specific language) and is easily extendable.



## Usage

You can pass this tool any number of Lua source files.
These files are loaded by `dofile()`, and have some helper functions
available that they use to generate and transform a list of op-codes,
in a way that looks similar to an assembler source file.

Lua is the macro programming language of this "assembly-like" DSL,
and the Lua functions are the "assembler mnemonics".

```
./assembler.lua asm/hello.asm.lua > hello.hex
```



## Example

hello.asm.lua:
```
dofile("lib/t3lc_mini.lua")
WRITE_C("H")
WRITE_C("e")
WRITE_C("l")
WRITE_C("l")
WRITE_C("o")
HALT()
```

```
$ ./assembler.lua test.asm.lua
```



# t3lc assembler mnemonics

TODO: Write a short description for every mnemonics

## t3lc CPU mnemonics

These apply to all t3lc implementations.

### OP(source, target)

### IMM(value, target)

### HALT()

### CLEAR_ACC()

### PERI0_WRITE(source)

### PERI1_WRITE(source)

### STR(str)

### STRR(str)

### PUSH(source)

### POP(target)

### STORE(source)

### LOAD(target)


## t3lc Mini mnemonics

This applies to the Mini-configuration of the t3lc.
