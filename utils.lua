-- shared utillities between the assembler and emulator

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
