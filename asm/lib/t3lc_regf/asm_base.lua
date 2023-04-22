--[[ Base instructions ]]--

-- regular instruction(no special OP):
-- write the value of source into target
function OP(source, target)
	output(t3lc_op_data(source, target))
end

-- immediate value:
-- load imm_val into REG_IMM
function REG_IMM(imm_val)
	output(t3lc_op_imm_reg(imm_val))
end



--[[ Special instructions ]]--

-- stop execution
function HALT()
	output(SPECIAL_OPS.HALT)
end

-- increase the SP
function PUSH()
	output(SPECIAL_OPS.PUSH)
end

-- decrease the SP
function POP()
	output(SPECIAL_OPS.POP)
end

-- clear the ACC register in the ALU
function CLEAR_ACC()
	output(SPECIAL_OPS.CLEAR_ACC)
end

-- if TOS is 0, jump to REGF_IJ
function BRANCH()
	output(SPECIAL_OPS.BRANCH)
end

-- jump to REGF_IJ
function JUMP()
	output(SPECIAL_OPS.JUMP)
end

-- write the REGF_I address from REG_IMM
function REGF_I_ADDR()
	output(SPECIAL_OPS.REGF_I_ADDR)
end

-- write the REGF_J address from REG_IMM
function REGF_J_ADDR()
	output(SPECIAL_OPS.REGF_J_ADDR)
end

