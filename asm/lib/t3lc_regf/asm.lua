require("asm.t3lc_regf.header")

--[[ Assembler-style functions(mnemonic) ]]--

-- stop execution
-- generates 1 instruction
function HALT()
	output(SPECIAL_OPS.HALT)
end

-- clear the ACC register in the ALU
-- generates 1 instruction
function CLEAR_ACC()
	output(SPECIAL_OPS.CLEAR_ACC)
end

-- select the index for the first register file
function INDEX_A(reg_i)
	IMM(reg_i)
	output(SPECIAL_OPS.REGF_A_I)
end

-- select the index for the second register file
function INDEX_B(reg_i)
	IMM(reg_i)
	output(SPECIAL_OPS.REGF_B_I)
end

-- output an op-code or two where the source might come from an immediate value
-- generates 1(supported power of 2 or target is REG_IMM) or 2(load REG_IMM and copy) instructions.
function OP(source_val, target)
	if not DATA_SOURCES[val] then
		local imm = assert_imm(val)
		if DATA_SOURCES_IMM[imm] then
			source = DATA_SOURCES_IMM[imm]
		else
			output(t3lc_op_imm_reg(imm))
			source = "REG_IMM"
		end
	end
	assert_source(source)
	output(t3lc_op_data(source, target))
end

-- perform operation on the DATA bus.
-- The selected source and target get connected on DATA bus,
-- and some data is transfered.
-- All instructions except IMM can be encoded using this mnemonic.
-- generates 1 instruction.
function MOV(source, target)
	assert_source(source)
	assert_target(target)
	output(t3lc_op_data(source, target))
end

-- load an immediate into a target
-- the numbers 0,2,4,8,16,128 can be loaded directly from an instruction
-- other numbers between 0-127 can be loaded
-- into REG_IMM, then copied into the target register.
-- generates 1(supported power of 2 or target is REG_IMM) or 2(load REG_IMM and copy) instructions.
function IMM(value, target)
	value = assert_imm(value)
	target = target or "REG_IMM"
	assert_target(target)
	if DATA_SOURCES_IMM[value] then
		output(t3lc_op_imm_bus(value, target))
	else
		output(t3lc_op_imm_reg(value))
		if target ~= "REG_IMM" then
			OP("REG_IMM", target)
		end
	end
end

-- push the string to the stack(length in REG_IMM)
-- generates #str+1 instructions
function STR(str)
	assert(type(str)=="string")
	assert(#str>1)
	for i=1, str do
		local char = str:byte(i,i)
		assert(char<128)
		IMM(char)
	end
	IMM(#str)
end

-- push from a source on the DATA bus
-- generates 1 or 2(IMM) instructions
function PUSH(source_or_imm)
	op_source_or_imm(source_or_imm, "PUSH")
end

-- pop as a target on the DATA bus
-- generates 2 instructions
function POP(target)
	assert_target(target)
	output(SPECIAL_OPS.POP)
	OP("TOS", target)
end

-- write source to RAM
-- generates 1 or 2(IMM) instructions
function STORE(source_or_imm)
	op_source_or_imm(source_or_imm, "RAM")
end

-- read from RAM to target
-- generates 1 or 2(IMM) instructions
function LOAD(target)
	OP("RAM", target)
end

-- perform ALU operation on REG_A and REG_B
function ALU(alu_op, target, enable_acc)
	alu_op = assert(ALU_OPS[alu_op])
	if enable_acc then
		alu_op = alu_op + 0x10
	end
	IMM(alu_op)
	OP("ALU", target)
end

-- jump to 16-bit addr
function JUMP(addr)
	if addr == "REG_I+REG_J" then
		OP("REG_I", "CNT_PC")
	else
		addr = assert(assert_range(assert_integer(addr), 0, 0x7f7f))
		assert(bit.band(addr, 0x80) == 0)
		local imm_i = bit.band(addr, 0x7f)
		local imm_j = bit.band(addr, 0x7f00) / 256
		IMM(imm_i, "REG_I")
		IMM(imm_j, "REG_J")
		OP("REG_I", "CNT_PC")
	end
end

-- jump to 14-bit addr
function JUMP_14(addr_14)
	addr = assert(assert_range(assert_integer(addr), 0, 0x3fff))
	local addr_i = bit.band(addr_14, 0x7f)
	local addr_j = bit.band(addr_14, 0x03f0) / 16
	local addr_16 = addr_i + addr_j*256
	JUMP_16(addr_16)
end

-- jump to addr if REG_B is 0
function BRANCH(addr)
	addr = assert(assert_range(assert_integer(addr), 0, 0x07f0))
	assert((addr % 16) == 0)
	IMM(addr/16)
	output(SPECIAL_OPS.BRANCH)
end

-- write next instructions starting at addr
-- generates no instructions
function AT(addr)
	cur_i = addr
end

function LABEL(name)
	local new_i = math.floor(cur_i / 16)
	if (cur_i % 16) ~= 0 then
		new_i = new_i + 1
	end
	new_i = new_i * 16
	AT(new_i)
end
