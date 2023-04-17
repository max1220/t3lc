require("lib.t3lc_mini")

cur_i = 0
	WRITE_STR("Hello!\n")
	OP(0x01, "REG_A")

cur_i = 16
	WRITE_C(".")
	ALU("LSHIFT1", "REG_A", )
	GPIO("REG_A")
	OP("REG_A","REG_B")
	BRANCH(32)
	JUMP(16)

cur_i = 32
	WRITE_STR("Bye!\n")
	HALT()
