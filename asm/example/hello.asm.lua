require("asm.lib.t3lc_regf.header")
require("asm.lib.t3lc_regf.asm_base")
require("utils.lua")

-- push the string onto the stack
local function immstr(str)0
	for i=1, #str do
		REG_IMM(str:sub(i,i))
	end
	REG_IMM(#str)
end
function lo(addr) return addr % 256 end
function hi(addr) return (addr-lo(addr))/256 end

-- code starts by pusing hello world onto the stack
immstr(("Hello World!\0"):reverse())

-- initialize REGF_A[0] and REGF_B[0] to 0
INDEX_IMM_OP("REGF_A", 0, "IMM_0")
INDEX_IMM_OP("REGF_B", 0, "IMM_0")

-- set loop end address in REGF_I[1] and REGF_J[1]
local loop_end = 0x0040
INDEX_IMM_OP("REGF_I", 1, lo(loop_start))
INDEX_IMM_OP("REGF_J", 1, hi(loop_start))

-- set loop base address in REGF_I[0] and REGF_J[0]
local loop_base = 0x0020
INDEX_IMM_OP("REGF_I", 0, lo(loop_base))
INDEX_IMM_OP("REGF_J", 0, hi(loop_base))

-- jump to loop base
JUMP()

-- beginning of output loop
cur_i = loop_base

	-- get current stack value
	INDEX_IMM_OP("REGF_A", 0, "TOS")
	OP("TOS", "REGF_A")
	-- load 0 into REGF_B
	OP("IMM_0", "REGF_B")

	-- branch to REGF_I[0] REGF_J[0] if REGF_A and REGF_B are equal
	IMM(ALU_OPS.EQ)
	OP("TOS", "ALU_AB")
	INDEX_REGF("REGF_I", 0)
	INDEX_REGF("REGF_J", 0)
	BRANCH()

	-- not equal to 0, write original value back
	OP("REGF_A", "TOS")

	-- move stack index
	POP()

	-- jump to loop start
	INDEX_IMM_OP("REGF_I", 1, lo(loop_pos))
	INDEX_IMM_OP("REGF_J", 1, hi(loop_pos))
	JUMP()

-- end of loop
cur_i = loop_end
