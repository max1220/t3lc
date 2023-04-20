--[[ Assembler utillity functions ]]--

-- index the specified register file from REG_IMM, optionally load REG_IMM first
function INDEX(regf, imm)
	assert_regf(regf)
	if imm then
		REG_IMM(imm)
	end
	if regf == "REGF_A" then
		INDEX_A()
	elseif regf == "REGF_B" then
		INDEX_B()
	end
end

-- index both register files(can save a single instruction)
function DINDEX(imm_a, imm_b)
	if imm_a==imm_b then
		REG_IMM(imm_a)
		INDEX_A()
		INDEX_B()
	else
		INDEX("REGF_A", imm_a)
		INDEX("REGF_B", imm_b)
	end
end

-- source_val is a DATA_SOURCE, index for register file, or immediate value
function get_source(source_val)
	if (type(source_val) == "string") and (source_val:sub(1,1)=="R") then
		local reg_f = assert(tonumber(source_val:sub(2,2)))
		local reg_i = assert(tonumber(source_val:sub(3)))
		INDEX(reg_f, reg_i)
		return reg_f
	elseif DATA_SOURCES[source_val] then
		return source_val
	elseif DATA_SOURCES_IMM[source_val] then
		return DATA_SOURCES_IMM[source_val]
	elseif tonumber(source_val) then
		REG_IMM(source_val)
		return "REG_IMM"
	end
end

-- target_val is a DATA_TARGET or index for register file
function get_target(target_val)
	if (type(target_val)=="string") and (target_val:sub(1,1) == "R") then
		local reg_f = "REGF_"..target_val:sub(2,2)
		local reg_i = assert(tonumber(target_val:sub(3)))
		INDEX(reg_f, reg_i)
		return reg_f
	elseif DATA_TARGETS[target_val] then
		return target_val
	end
end

-- move data from source_val to target_val
function MOV(source_val, target_val)
	if source_val == "REG_IMM" then
		assert_target(target_val)
		output(t3lc_encode_op_data("REG_IMM", DATA_TARGETS[target_val]))
		return
	end
	local target = assert_target(get_target(target_val))
	local source = assert_source(get_source(source_val))
	assert(source_val~="REG_IMM")
	output(t3lc_encode_op_data(source, target))
end

-- load an immediate into a target
-- the numbers 0,1,2,4,8,16,128 can be loaded directly,
-- other numbers between 0-127 can be loaded into REG_IMM and copied into target.
function IMM(value, target)
	value = assert_imm(value)
	if DATA_SOURCES_IMM[value] and target then
		output(t3lc_encode_op_imm_bus(value, target))
	elseif target_val then
		output(t3lc_encode_op_imm_reg(value))
		OP("REG_IMM", target)
	else
		output(t3lc_encode_op_imm_reg(value))
	end
end

-- push the string to the stack(length in REG_IMM)
-- generates #str+1 instructions
function STR(str)
	assert(type(str)=="string")
	assert(#str>1)
	assert(#str<128)
	for i=1, str do
		local char = str:byte(i,i)
		assert(char<128)
		IMM(char)
	end
	IMM(#str)
end

-- push from a source on the DATA bus
function PUSHV(source_val)
	local source = assert_source(get_source(source_val))
	PUSH()
	OP(source, "TOS")
end

-- pop as a target on the DATA bus
function POPV(target_val)
	local target = assert_target(get_target(target_val))
	OP("TOS", target)
	POP()
end

-- write source to RAM
function STORE(source)
	local source = source
	OP(source, "RAM")
end

-- read from RAM to target
function LOAD(target)
	local target = target
	OP("RAM", target)
end

-- perform ALU operation on REG_A and REG_B
function ALU(alu_op, alu_source, target, enable_acc)
	alu_op = assert(ALU_OPS[alu_op])
	if enable_acc then
		alu_op = alu_op + 0x10
	end
	IMM(alu_op)
	if alu_source == "AB" then
		OP("ALU_AB", target)
	elseif alu_source == "SD" then
		OP("ALU_DS", target)
	end
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
