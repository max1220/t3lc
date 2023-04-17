# emulator.lua

*Modular emulator for the t3lc.*

This file implements a modular emulator for the t3lc CPU.



## Usage

```
cd emu
./emulator.lua [-d/--debug] rom_file [target_file]
```

`rom_file` must be a path to a file that is used as the backing for the
ROM storage.

`target_file` is an optional path to a CPU/board definition
(defaults to `t3lc_core.lua`).

`-d/--debug` prints a human-readable trace log of
the instructions as they are run to stderr.
