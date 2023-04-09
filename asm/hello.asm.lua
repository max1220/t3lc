dofile("lib/t3lc.lua")

function OUTC()
	IMM_REG()
	_ "STORE REG_IMM"
end

_ "IMM 0x7F REG_I"
_ "IMM 0x7F REG_J"
_ "OUTC H"
_ "OUTC e"
_ "OUTC l"
_ "OUTC l"
_ "OUTC o"
_ "IMM_REG 0x20"
_ "STORE REG_IMM"
_ "OUTC W"
_ "OUTC o"
_ "OUTC r"
_ "OUTC l"
_ "OUTC d"
_ "IMM_REG 0x20"
_ "STORE REG_IMM"
_ "IMM 0x00 REG_I"
_ "IMM 0x00 REG_J"
_ "OP IMM_0 CNT_PC"
