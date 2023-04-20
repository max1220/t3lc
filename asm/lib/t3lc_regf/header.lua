--[[ t3lc CPU definition ]]--

-- sources of the DATA bus
-- bits 0,1,2,3 from ROM_VALUE(op-code)
DATA_SOURCES = {
	REGF_A=0, REGF_B=1, TOS=2, ALU_AB=3,
	ALU_SD=4, PERI0=5, PERI1=6, RAM=7,
	REG_IMM=8, IMM_0=9, IMM_1=10, IMM_2=11,
	IMM_4=12, IMM_8=13, IMM_16=14, IMM_128=15
}
DATA_SOURCES_IMM = {
	[0] = "IMM_0", [1] = "IMM_1", [2] = "IMM_2", [4] = "IMM_4",
	[8] = "IMM_8", [16] = "IMM_16", [128] = "IMM_128"
}

-- targets of the DATA bus
-- bits 4,5,6 from ROM_VALUE(op-code)
DATA_TARGETS = {
	REGF_A=0, REGF_B=1, TOS=2, REG_I=3,
	REG_J=4, PERI0=5, PERI1=6, RAM=7
}

-- ALU operations
-- bits 0,1,2,3 from REG_IMM
ALU_OPS = {
	ADD=0, SUB=1, MUL=2, DIV=3,
	AND=4, OR=5, XOR=6, NOT=7,
	LSHIFT1=8, LSHIFT=9, RSHIFT1=10, RSHIFT=11
	NEG=12, GT=13, EQ=14, ACC=15
}

-- special instructions
-- these all are op-codes with source == target
SPECIAL_OPS = {
	HALT = 0x00,
	PUSH = 0x11,
	POP = 0x22,
	CLEAR_ACC = 0x33,
	BRANCH = 0x44,
	JUMP = 0x55,
	REGF_A_I = 0x66,
	REGF_B_I = 0x77
}



-- assert that source_index exists
function assert_source(source_index)
	assert(DATA_SOURCES[source_index])
	return source_index
end

-- assert that target_index exists
function assert_target(target_index)
	assert(DATA_TARGETS[target_index])
	return target_index
end

-- assert that value fits into an REG_IMM instruction(is 7-bit)
function assert_imm(value)
	if (type(value) == "string") and (#value==1) then
		value = value:byte()
	end
	return assert_range(assert_integer(value), 0, 127)
end

-- assert that regf_name is valid
function assert_regf(regf_name)
	assert((regf_name=="REGF_A") or (regf_name=="REGF_B"))
	return regf_name
end



-- return op-code that configures the DATA bus
function t3lc_encode_op_data(source, target)
	local source_op = DATA_SOURCES[assert_source(source)]
	local target_op = DATA_TARGETS[assert_target(target)]

	-- exclude special instructions
	assert(source_op ~= target_op)

	return source_op + target_op * 0x10
end

-- return op-code to write to REG_IMM
function t3lc_encode_op_imm_reg(value)
	return 128+assert_imm(value)
end

-- return op-code to write to target
function t3lc_encode_op_imm_bus(imm, target)
	return t3lc_encode_op_data(assert(DATA_SOURCES_IMM[imm]), assert_target(target))
end

-- return a human-readable name for the op-code
function t3lc_decode_op(op_code)
	assert(type(op_code)=="number")
	assert(op_code>=0)
	assert(op_code<256)
	if value >= 128 then
		return ("REG_IMM 0x%.2x"):format(op_code-128)
	else
		local source_val = value % 0x10
		local target_val = (value - source_val) / 0x10
		for name,special_op in pairs(SPECIAL_OPS) do
			if special_op == op_code then
				return name
			end
		end
		local source_name
		local target_name
		for name,val in pairs(DATA_SOURCES) do
			if val == source_val then source_name = name end
		end
		for name,val in pairs(DATA_TARGETS) do
			if val == target_val then target_name = name end
		end
		assert(source_name)
		assert(target_name)
		return "OP " .. source_name .. " " .. target_name
	end
end

