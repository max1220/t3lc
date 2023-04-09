--[[ Setup encoded op-code format ]]--



--[[ TTA CPU definition ]]--

-- 4 bits to select source of the DATA bus
DATA_SOURCES = {
	REG_A=0, REG_B=1, REG_I=2, REG_J=3,
	POP=4, TOS=5, ALU=6, RAM=7,
	REG_IMM=8, IMM_0=9, IMM_1=10, IMM_2=11,
	IMM_4=12, IMM_8=13, IMM_16=14, IMM_128=15
}

-- 3 bits to select target of the DATA bus
DATA_TARGETS = {
	REG_A=0, REG_B=1, REG_I=2, REG_J=3,
	CNT_PC=4, PUSH=5, SP=6, RAM=7
}
-- 3 bits to select ALU operation
ALU_OPS = {
	ADD=0, AND=1, OR=2, NOT=3,
	LSHIFT=4, MUL=5, GT=6, EQ=7
}

-- look up how to encode a value using the IMM_* DATA bus sources.
IMM_VALUES= {
	[0] = "IMM_0", [1] = "IMM_1", [2] = "IMM_2", [4] = "IMM_4",
	[8] = "IMM_8", [16] = "IMM_16", [128] = "IMM_128"
}

-- return op-code that configures the DATA bus
function t3lc_op_data(source, target)
	local source_op = assert(DATA_SOURCES[source])
	local target_op = assert(DATA_TARGETS[target])
	return source_op + target_op * 0x10
end

-- return op-code to write to REG_IMM
function t3lc_op_imm_reg(v)
	assert(type(v)=="number")
	assert(v>=0)
	assert(v<128)
	return 128+math.floor(v)
end

-- return op-code to copy an immediate value directly to target
-- only certain powers of two can be encoded this way
function t3lc_op_imm_bus(v, target)
	local source_op = assert(DATA_SOURCES[assert(IMM_VALUES[v])])
	local target_op = assert(DATA_TARGETS[target])
	return source_op + target_op * 0x10
end

-- utillity functions for gettins a source/target from the token stack
function token_pop_source()
	local source = token_pop()
	assert(DATA_SOURCES[source])
	return source
end
function token_pop_target()
	local target = token_pop()
	assert(DATA_TARGETS[target])
	return target
end



-- perform operation on the main DATA bus
-- when this instruction is running, the selected source and
-- target get connected via the DATA bus, and some data is transfered.
-- generates 1 instruction.
function OP()
	local source = token_pop_source()
	local target = token_pop_target()
	output(t3lc_op_data(source, target))
end
MOV = OP

-- write an immediate value to REG_IMM
-- immediate value must be <128
-- generates 1 instruction
function REG_IMM()
	local value = token_pop_num()
	output(t3lc_op_imm(value))
end

-- load an immediate into a register
-- the numbers 0,2,4,8,16,128 can be loaded
-- directly from an instruction into a register.
-- other numbers between 0-127 can be loaded
-- into REG_IMM, then copied into the target register.
-- generates 1(supported power of 2) or 2(load REG_IMM and copy) instructions.
function IMM()
	local value = token_pop_num()
	local target = token_pop_target()
	if IMM_VALUES[value] then
		output(t3lc_op_imm_bus(value, target))
	else
		output(t3lc_op_imm_reg(value))
		if target ~= "REG_IMM" then
			output(t3lc_op_data("REG_IMM", target))
		end
	end
end

-- push an ASCII string to the stack
-- generates a series of load-immediates and store-stacks.
-- characters must be in ASCII-range(7-bit).
-- generates #str*2 instructions.
function PUSH_ASCII()
	local char = token_pop_ascii()
	local val
	if type(char)=="string" then
		assert(#char==1)
		val = char:byte()
	elseif type(char)=="number" then
		val = char
	end
	assert(val<128)
	output(t3lc_op_imm_reg(char))
	output(t3lc_op_data("REG_IMM", "PUSH"))
	end
end

-- push from a source on the DATA bus
-- generates 1 instruction
function PUSH()
	local source = token_pop_source()
	output(t3lc_op_data(source, "PUSH"))
end

-- push an immediate value
-- generates 1(supported power of 2) or 2(load REG_IMM and copy) instructions.
function PUSH_IMM()
	local value = token_pop_num()
	if IMM_VALUES[value] then
		output(t3lc_op_imm_bus(value, "PUSH"))
	else
		output(t3lc_op_imm_reg(value))
		output(t3lc_op_data("REG_IMM", "PUSH"))
	end
end

-- POP a value from the stack
function POP()
	local target = pop()
	output(t3lc_op_data("POP", target))
end

-- write a value to memory
function STORE()
	local source = pop()
	output(t3lc_op_data(source, "RAM"))
end

-- read a value from memory
function LOAD()
	local target = pop()
	output(t3lc_op_data("RAM", target))
end

