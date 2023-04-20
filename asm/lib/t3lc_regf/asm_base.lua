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
function PUSH()
	output(SPECIAL_OPS.POP)
end

-- clear the ACC register in the ALU
function CLEAR_ACC()
	output(SPECIAL_OPS.CLEAR_ACC)
end

-- if TOS is 0, jump to REGF_AB
function BRANCH()
	output(SPECIAL_OPS.BRANCH)
end

-- jump to REGF_AB
function JUMP()
	output(SPECIAL_OPS.JUMP)
end

-- write the index for the first register file from REG_IMM
function INDEX_A()
	output(SPECIAL_OPS.REGF_A_I)
end

-- write the index for the first second file from REG_IMM
function INDEX_B()
	output(SPECIAL_OPS.REGF_B_I)
end

