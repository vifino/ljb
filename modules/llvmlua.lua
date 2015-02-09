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
		local func,err = loadstring(luacode[infile])
		if func then
			local f = io.popen(string.format("%s -O3 -s -bc %s -o %s", llvm_luac, "-", outfile),"w")
			f:write(luacode[infile])
			f:close()
		else
			fatal(err)
		end
	else
		local f = io.popen(string.format("%s -O3 -s -bc %s -o %s", llvm_luac, "-", outfile),"w")
		f:write(luacode[infile])
		f:close()
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
addOption("l",function()
	libtool = (os.getenv("libtool_bin") or "libtool") .. " --tag=CC --silent"
	llvm_luac = os.getenv("llvm-luac") or "llvm-luac"
	compile = compile_llvmlua
	buildObj = buildObj_llvmlua
end, "Compile file with LLVM-Lua.")
