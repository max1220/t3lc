--[[ t3lc CPU definition ]]--

-- sources of the DATA bus
-- bits 0,1,2,3 from ROM_VALUE(op-code)
DATA_SOURCES = {
	REGF_A=0, REGF_B=1, TOS=2, REG_IMM=3,
	ALU=4, PERI0=5, PERI1=6, RAM=7,
	IMM_0=8, IMM_1=9, IMM_2=10, IMM_4=11,
	IMM_8=12, IMM_16=13, IMM_32=14, IMM_128=15
}
DATA_SOURCES_IMM = {
	[0] = "IMM_0", [1] = "IMM_1", [2] = "IMM_2", [4] = "IMM_4",
	[8] = "IMM_8", [16] = "IMM_16", [32] = "IMM_32", [128] = "IMM_128"
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
