-- enable run_debug if "-d"/"--debug" is first argument
run_debug = false
if (arg[1] == "-d") or (arg[1] == "--debug") then
	io.stderr:write("Enabling debug output!\n")
	table.remove(arg, 1)
	run_debug = true
end

-- print to stderr if run_debug is set
function log(...)
	if not run_debug then return end
	for i=1, select("#", ...) do
		io.stderr:write(tostring(select(i, ...)))
	end
	io.stderr:write("\n")
end

-- load required ROM data
local rom_path = assert(table.remove(arg, 1))
log("Reading ROM data from: ",rom_path)
rom_data = assert(io.read(rom_path, "rb"))

-- load core file(default to t3lc_core.lua)
if arg[1] then
	require(table.remove(arg, 1))
else
	require("target.t3lc_core")
end

-- run the CPU until HALT
log("== STARTED =============================================================")
while state.run do
	if run_debug then
		step_debug()
	else
		step()
	end
end
log("== STOPPED =============================================================")
