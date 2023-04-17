function assert_source(source)
	assert(DATA_SOURCES[source])
	return source
end
function assert_target(target)
	assert(DATA_TARGETS[target])
	return target
end
function assert_imm(value)
	if (type(value) == "string") and (#value==1) then
		value = value:byte()
	end
	return assert_range(assert_integer(value), 0, 127)
end
function assert_source_imm(value)
	assert(DATA_SOURCES_IMM[value])
	return value
end



-- return op-code that configures the DATA bus
function t3lc_op_data(source, target)
	local source_op = DATA_SOURCES[assert_source(source)]
	local target_op = DATA_TARGETS[assert_target(target)]
	return source_op + target_op * 0x10
end

-- return op-code to write to REG_IMM
function t3lc_op_imm_reg(value)
	return 128+assert_imm(value)
end

-- return op-code to copy an immediate value directly to target
-- only certain powers of two can be encoded this way
function t3lc_op_imm_bus(value, target)
	local source_name = DATA_SOURCES[assert_source_imm(value)]
	local source_op = DATA_SOURCES[DATA_SOURCES_IMM[value]]
	local target_op = DATA_TARGETS[assert_target(target)]
	return source_op + target_op * 0x10
end
