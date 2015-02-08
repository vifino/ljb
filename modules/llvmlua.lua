-- Compile file with LLVM-Lua runtime, not luajit.
-- TBD
-- Compile file with LuaJIT. [Default]
function buildObj_llvmlua(infile, outfile, name)
	outfile = outfile .. ".bc"
	if not name then
		fatal("LLVM-Lua does not support modules for now.")
	end
	local dir, filename, extension = string.match(infile, "(.-)([^/]-([^%.]+))$")
	name = name or (dir:gsub("^%./",""):gsub("^/",""):gsub("/",".") .. filename:gsub("%.lua$",""))
	if not nocheckfile and infile then
		local file = assert(io.open(infile))
		local content = file:read("*all")
		file:close()
		local func,err = loadstring(content)
		if func then
			run(string.format("%s -O3 -s -bc %s -o %s", llvm_luac, infile, outfile))
		else
			fatal(err)
		end
	else
		run(string.format("%s -O3 -s -bc %s -o %s", llvm_luac, infile, outfile))
	end
	return outfile
end
function compile_llvmlua(fargs)
	local cmd = string.format([[
	%s -Wl,-E -O%s \
		-fomit-frame-pointer -pipe \
		%s \
		-o %s -lm -ldl]], (os.getenv("LLVM_CC") or "clang"), optimisationlevel, (arg[1]..".bc"), arg[2])
	local b = os.execute(cmd)
	os.execute("rm -rf "..arg[1]..".bc")
end
addOption("v",function()
	libtool = (os.getenv("libtool_bin") or "libtool") .. " --tag=CC --silent"
	llvm_luac = os.getenv("llvm-luac") or "llvm-luac"
	compile = compile_llvmlua
	buildObj = buildObj_llvmlua
end, "Compile file with LLVM-Lua.")
