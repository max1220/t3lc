local bit = require("bit")
require("asm.lib.t3lc_header")

function new_state(rom_data)
	state.REGF_A_ADDR = 0x00
	state.REGF_B_ADDR = 0x00
	state.REGF_I_ADDR = 0x00
	state.REGF_J_ADDR = 0x00
	state.REGF_A = {}
	state.REGF_B = {}
	state.REGF_I = {}
	state.REGF_J = {}
	state.REG_IMM = 0x00
	state.REG_ACC = 0x00
	state.CNT_PC = 0x0000
	state.CNT_SP = 0x00
	state.last_imm = false
	state.rom_data = rom_data
	state.stack = {}
	state.ram = {}
	state.run = true
end
state = new_state(rom_data)



function regf_read(regf)
	if regf == "REGF_A" then
		return state.REGF_A[state.REGF_A_ADDR]
	elseif regf == "REGF_B" then
		return state.REGF_B[state.REGF_B_ADDR]
	elseif regf == "REGF_I" then
		return state.REGF_I[state.REG_IMM]
	elseif regf == "REGF_J" then
		return state.REGF_J[state.REG_IMM]
	else
		error()
	end
end
function regf_write(regf, value)
	if regf == "REGF_A" then
		state.REGF_A[state.REGF_A_ADDR] = value
	elseif regf == "REGF_B" then
		state.REGF_B[state.REGF_B_ADDR] = value
	elseif regf == "REGF_I" then
		state.REGF_I[state.REG_IMM] = value
	elseif regf == "REGF_J" then
		state.REGF_J[state.REG_IMM] = value
	else
end
function rom_read(addr)
	return state.rom_data:byte(addr+1, addr+1)
end
function ram_read()
	local addr = state.REG_I + state.REG_J*256
	return state.ram[addr] or 0
end
function ram_write(value)
	local addr = state.REG_I + state.REG_J*256
	self.ram[addr] = value
end
function incr_sp()
end
function decr_sp()
end
function tos_read()
end
function tos_write(value)
end
function push(value)
	state.stack[state.CNT_SP] = value
	state.CNT_SP = bit.band(state.CNT_SP + 1, 0xffff)
end
function alu()
	local alu_op = bit.band(state.REG_IMM, 0x0f)
	if alu_op==0 then
		local res = state.REG_A + state.REG_B
		local carry = bit.band(res, 0x100)
		state.REG_ACC = carry
		return bit.band(res, 0xff)
	end
	-- TODO: Implement other ALU ops
	return 0
end
function data_get(source)
	if source==DATA_SOURCES.REG_A return state.REG_A
	elseif source==DATA_SOURCES.REG_B return state.REG_B
	elseif source==DATA_SOURCES.REG_I return state.REG_I
	elseif source==DATA_SOURCES.REG_J return state.REG_J
	elseif source==DATA_SOURCES.TOS return state.stack[self.CNT_SP]
	elseif source==DATA_SOURCES.ALU return alu()
	elseif source==DATA_SOURCES.REG_IMM return state.REG_IMM
	elseif source==DATA_SOURCES.RAM return ram_read()
	elseif source==DATA_SOURCES.IMM_0 return 0
	elseif source==DATA_SOURCES.IMM_1 return 1
	elseif source==DATA_SOURCES.IMM_2 return 2
	elseif source==DATA_SOURCES.IMM_4 return 4
	elseif source==DATA_SOURCES.IMM_8 return 8
	elseif source==DATA_SOURCES.IMM_16 return 16
	elseif source==DATA_SOURCES.IMM_32 return 32
	elseif source==DATA_SOURCES.IMM_128 return 128
	end
end
function data_write(value, target)
	if target==DATA_TARGETS.REG_A then state.REG_A = value
	elseif target==DATA_TARGETS.REG_B then state.REG_B = value
	elseif target==DATA_TARGETS.REG_I then state.REG_I = value
	elseif target==DATA_TARGETS.REG_J then state.REG_J = value
	elseif target==DATA_TARGETS.CNT_PC then state.CNT_PC = value
	elseif target==DATA_TARGETS.PUSH then push(value)
	elseif target==DATA_TARGETS.CNT_SP then self.CNT_SP = value
	elseif target==DATA_TARGETS.RAM then ram_write(value)
	end
end

-- op-code decoding table
ops = {}
op_names = {}
local function gen_op(op_code)
	local source = bit.band(op_code)
	local target = bit.band(op_code, 0x70) / 16
	return function()
		data_write(data_get(source), target)
		state.last_imm = false
	end
end
local function gen_imm(op_code)
	return function()
		if state.last_imm then
			push(state.REG_IMM)
		end
		state.REG_IMM = bit.band(op_code, 0x7f)
		state.last_imm = true
	end
end
local function add_op(op_code, name, cb)
	ops[op_code] = cb
	op_names[op_code] = name
end
for i=0x00, 0xff do
	local cb = (i<0x80) and gen_op(i) or gen_imm(i)
	add_op(i, op_name(i), cb)
end
add_op(0x00, "HALT", function() state.run = false end)
add_op(0x11, "CLEAR_ACC", function() state.REG_ACC = 0 end)
add_op(0x22, "PERI0_WRITE", function() end)
add_op(0x33, "PERI1_WRITE", function() end)
add_op(0x44, "BRANCH", function()
	if state.REG_B==0 then state.CNT_PC = state.REG_IMM * 16 end
end)
add_op(0x77, "POP", function()
	state.CNT_SP = (state.CNT_SP ~= 0) and (state.CNT_SP - 1) or 0xff
end)

-- run a single instruction from ROM
function step()
	local op = rom_read(state.CNT_PC)
	ops[op]()
end

-- run a single instruction from ROM, print trace to STDERR
function step_debug()
	local op = read_rom(state.CNT_PC)
	io.stderr:write(("[PC %.4x = %.2x(%10s)] -> "):format(state.CNT_PC, op, op_names[op]))
	ops[op]()
	io.stderr:write(("[SP %.2x = %.2x] "):format(state.CNT_SP, data_get(DATA_SOURCES.TOS)))
	io.stderr:write(("[IMM %.2x = %.2x%s] "):format(state.REG_IMM, state.last_imm and " *" or ""))
	io.stderr:write(("[A %.2x] "):format(state.REG_A))
	io.stderr:write(("[B %.2x] "):format(state.REG_B))
	io.stderr:write(("[I %.2x] "):format(state.REG_I))
	io.stderr:write(("[J %.2x] "):format(state.REG_J))
	io.stderr:write(("[ACC %.2x = %.2x]\n"):format(state.REG_ACC))
end

