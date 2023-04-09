#!/usr/bin/env lua
-- assembler.lua
-- Simple, extendable Lua DSL for translating assembly to machine code.


--[[ State modified by source files ]]--
tokens = {}
macros = {}
ops = {}


--[[ functions that can be used in assembler souce files: ]]--

-- append the token(if string, split into tokens first)
function underscore(val)
	if type(val) == "string" then
		for str_token in val:gmatch("(%S+)%s?") do
			if tonumber(str_token) then
				table.insert(tokens, tonumber(str_token))
			else
				table.insert(tokens, str_token)
			end
		end
	else
		table.insert(tokens, val)
	end
end
_ = underscore

-- remove and return token from the top of the list of tokens
function token_pop()
	return table.remove(tokens, 1)
end
function token_pop_num()
	local num = table.remove(tokens, 1)
	num = math.floor(assert(tonumber(num)))
	return num
end
function token_pop_ascii()
	local char = table.remove(tokens, 1)
	local char_cod
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

-- add token to the top of the list of tokens
function token_push(v)
	table.insert(tokens, v, 1)
end

-- add a complete op-code to the list of op-codes
function output(v)
	table.insert(ops, v)
end

-- print to stderr
function log(...)
	for i=1, select("#", ...) do
		io.stderr:write(tostring(select(i, ...)))
	end
	io.stderr:write("\n")
end

-- turn a single op-code(number) into a string representation of this op-code
-- This function can be user-overridden, but defaults to hex-dump.
function encode_op(op)
	return ("0x%x\n"):format(op)
end

-- load all source files
for i=1, #arg do
	log("loading", arg[i], "...")
	dofile(arg[i])
end




-- process tokens until finished
log("processing...")
while #tokens > 0 do
	local token = pop()
	log(("current token: %s, remaining tokens: %d, generated ops: %d"):format(tostring(token), #tokens, #ops))
	if (type(token) == "number") or tonumber(token) then
		output(tonumber(token))
	elseif type(_G[token]=="function") then
		_G[token]()
	else
		error("Unknown token:"..tostring(token))
	end
end

-- write resulting op-codes to file
log("Writing opcodes...")
for i=1, #ops do
	io.write(encode_op(ops[i]))
end
