function encode_op(op)
	op = math.floor(assert(tonumber(op)))
	assert(op>=0)
	assert(op<256)
	return ("%.2x\n"):format(op)
end
