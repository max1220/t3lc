#!/usr/bin/env lua
-- assembler.lua
-- This file implements a small DSL for creating Lua scripts
-- that generate machine code from assembly.
bit = require("bit")



-- this table holds the generated op-codes
ops = {}
max_i = 0
cur_i = 0

-- functions for adding generated op-codes
function output(v)
	ops[cur_i] = v
	cur_i = cur_i + 1
	max_i = math.max(cur_i, max_i)
end
function output_at(i, v)
	ops[i] = v
	max_i = math.max(i+1, max_i)
end

-- utillity functions for scripts
function assert_integer(num)
	return math.floor(assert(tonumber(num)))
end
function assert_range(num, min, max)
	assert(num>=min)
	assert(num<=max)
	return num
end
function assert_ascii(char)
	local char_code
	if type(char) == "string" then
		assert(#char==1)
		char_code = char:byte()
	elseif type(char) == "number"
		char_code = char
	else
		error()
	end
	assert(char_code>=0)
	assert(char_code<128)
	return char_code
end
function log(...)
	for i=1, select("#", ...) do
		io.stderr:write(tostring(select(i, ...)))
	end
	io.stderr:write("\n")
end

-- turn a single op-code(number) into a string representation of this op-code
function encode_op(op_value)
	local v = assert_range(assert_integer(op_value), 0, 255)
	return ("0x%.2x\n"):format(v)
	--return string.char(v)
end

-- process an op-code value into an output value
function process_op(cur_i, op_value)
	if type(op_value) == "function" then
		return op_value(cur_i)
	elseif type(op_value) == "number" then
		return encode_op(op_value)
	elseif type(op_value) == "string" then
		return assert(#op_value>0)
	else
		error("Unknown OP value:"..tostring(op_value))
	end
end

-- load source files, process op-codes, write to file(run the assembler)
local function run()
	-- load all source files
	for i=1, #arg do
		log("loading", arg[i], "...")
		dofile(arg[i])
	end

	-- process op-codes until all op-codes are strings
	while true do
		log("processing...")
		local is_only_strings = true
		for i=0, max_i-1 do
			local cur_op = ops[i]
			if cur_op then
				local new_op = process_op(cur_op)
				if type(new_op) ~= "string" then
					is_only_strings = false
				end
				ops[i] = new_op
			end
		end
		if is_only_strings then break end
	end

	-- write resulting op-codes to file
	log("Writing opcodes...")
	for i=0, max_i-1 do
		io.write(ops[i] or "\0")
	end
end
run()
