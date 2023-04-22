require("lib.t3lc_regf.header")
require("lib.t3lc_regf.asm_base")

-- push the string onto the stack
local function immstr(str)
	for i=1, #str do
		REG_IMM(str:sub(i,i))
	end
	REG_IMM(#str)
end

local function source_or_imm(source_val)
	if DATA_SOURCES[source_val] then
		return source_val
	else
		return "REG_IMM", source_val
	end
end

local function op_with_imm(imm, target)
	IMM(imm)
	OP("REG_IMM", target)
end

local function regf_ab(index_or_source, target)
	local source,imm = source_or_imm(index_or_source)
	if source then
		OP(source, target)
	else
		op_with_imm(source, target)
	end
end
function REGF_A(index_or_source)
	regf_ab(index_or_source, "REGF_A_ADDR")
end
function REGF_B(index_or_source)
	regf_ab(index_or_source, "REGF_B_ADDR")
end
function REGF_I(index)
	IMM(index)
	REGF_I_ADDR()
end
function REGF_J(index)
	IMM(index)
	REGF_I_ADDR()
end



-- code starts by pusing hello world onto the stack
immstr(("Hello World!\0"):reverse())

-- note current position(jump point for loop)
local loop_pos = cur_i

	-- get current stack value
	OP("TOS", "REGF_A")
	-- load 0 into REGF_B
	OP("IMM_0", "REGF_B")

	-- address for jump from immediate
	OP("IMM_128", "REGF_I")
	OP("IMM_0", "REGF_J")

	IMM(ALU_OPS.GT)
	OP("ALU_AB", "TOS")
	BRANCH()





-- end of loop
cur_i = 128
