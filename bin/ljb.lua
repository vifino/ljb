#!/usr/bin/env luajit
-- LuaJIT bundler/builder
-- Made by vifino

-- Helper functions.
function file_exists(name)
	if name then
		local f=io.open(name,"r")
		if f~=nil then
			io.close(f)
			return true
		else
			return false
		end
	end
end
function run(cmd)
	--print("$ "..cmd)
	return os.execute(cmd)
end
function exec(cmd)
	--print("$ "..cmd)
	local fd = io.popen(cmd)
	local content = fd:read("*all"):match("^%s*(.-)%s*$")
	fd:close()
	return content
end
function ansiescape(num)
	return (string.char(27) .. '[%dm'):format(num)
end
function perror(...)
	io.write(ansiescape(31).."[ERROR]".. ansiescape(0) .. " "..table.concat({...},"\t").."\n")
end
function fatal(...)
	io.write(ansiescape(31).."[FATAL]".. ansiescape(0) .. " "..table.concat({...},"\t").."\n")
	os.exit(1)
end
function pwarn(...)
	print(ansiescape(33).."[WARNG]".. ansiescape(0) .. " "..table.concat({...},"\t"))
end
function pinfo(...)
	print(ansiescape(32).."[INFO]".. ansiescape(0) .. " "..table.concat({...},"\t"))
end

function werror(...)
	io.write(ansiescape(31).."[ERROR]".. ansiescape(0) .. " "..table.concat({...},"\t"))
end
function wwarn(...)
	io.write(ansiescape(33).."[WARNING]".. ansiescape(0) .. " "..table.concat({...},"\t"))
end
function winfo(...)
	io.write(ansiescape(32).."[INFO]".. ansiescape(0) .. " "..table.concat({...},"\t"))
end
-- Done.

-- Option parser, mostly taken from the lua doc, just tweaked for my needs.
function getopt( options )
	local tab = {}
	for k, v in ipairs(arg) do
		if string.sub( v, 1, 2) == "--" then
			table.remove(arg,k)
			local x = string.find( v, "=", 1, true )
			if x then tab[ string.sub( v, 3, x-1 ) ] = string.sub( v, x+1 )
			else      tab[ string.sub( v, 3 ) ] = true
			end
		elseif string.sub( v, 1, 1 ) == "-" then
			table.remove(arg,k)
			local y = 2
			local l = string.len(v)
			local jopt
			while ( y <= l ) do
				jopt = string.sub( v, y, y )
				tab[ jopt ] = true
				y = y + 1
			end
		end
	end
	return tab
end
-- Done.

-- Some variables required later.
local nocheckfile = false
ccargs = ""
extra_objects = {}
extra_c = os.getenv("ljb_cadd") or ""
extra_inc = os.getenv("ljb_cpre") or ""
optimisationlevel = "3"
compile = nil
buildObj = nil
luacode = {}
ccode = [[
#include <stdio.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
]] .. extra_inc ..[[
int main(int argc, char *argv[]) {
	int i;
	lua_State* L = luaL_newstate();
	if (!L) {
		printf("Unable to initialize LuaJIT!\n");
	}
	luaL_openlibs(L);
]] .. extra_c .. [[
	lua_newtable(L);
	for (i = 0; i < argc; i++) {
		lua_pushnumber(L, i);
		lua_pushstring(L, argv[i]);
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");
	int ret = luaL_dostring(L, "require \"main\"");
	if (ret != 0) {
		printf(lua_tolstring(L, -1, 0));
		printf("\n");
		return ret;
	}
	return 0;
}
]]
ljbin = os.getenv("luajit_bin") or "luajit"
-- Done.

-- Option parsing functions.
local optionlist = "h"
local optionstore = {}
local optionsequence = {}
local optioninfo = {}

function addOption(character,fun, info)
	optionlist = optionlist .. character
	if not optionstore[character] then
		table.insert(optionsequence,character)
	end
	optionstore[character] = fun
	if info then
		optioninfo[character] = info
	end
end
-- PreProcessors.
local preprocessors = {}
function addPreProcessor(func)
	for i = 1,#preprocessors do
		if preprocessors[i] == func then
			return true
		end
	end
	table.insert(preprocessors, func)
end
-- Hooks.
local posthooks = {}
function addPostProcess(func)
	table.insert(posthooks, func)
end

-- Inbuild Options here.
addOption("q", function() -- No output, except Errors..
	function pwarn(...) end
	function pinfo(...) end
	function wwarn(...) end
	function winfo(...) end
	function print(...) end
end, "Quiet for the most part, excludes Errors.")

addOption("Q", function() -- No output at all.
	function perror(...) end
	function fatal() end
	function pwarn(...) end
	function pinfo(...) end
	function werror(...) end
	function wwarn(...) end
	function winfo(...) end
	function print(...) end
end)

addOption("N", function() -- No color.
	function perror(...)
		io.write("[ERROR] "..table.concat({...},"\t").."\n")
	end
	function fatal(...)
		io.write("[FATAL] "..table.concat({...},"\t").."\n")
		os.exit(1)
	end
	function pwarn(...)
		print("[WARNG] "..table.concat({...},"\t"))
	end
	function pinfo(...)
		print("[INFO] "..table.concat({...},"\t"))
	end
	function werror(...)
		io.write("[ERROR] "..table.concat({...},"\t"))
	end
	function wwarn(...)
		io.write("[WARNING] "..table.concat({...},"\t"))
	end
	function winfo(...)
		io.write("[INFO] "..table.concat({...},"\t"))
	end
end, "Don't use colors.")

addOption("s", function() -- Strip
	addPostProcess(function()
		optimisationlevel = "s"
		winfo("Stripping... ")
		local status = os.execute("strip --strip-all "..arg[2])
		if (type(status) == "number" and status/256 == 0) or (type(status) == "boolean" and status == true) then
			print("Done.")
		else
			print("Error!")
		end
	end)
end, "Use -Os and strip output file using 'strip --strip-all'")

addOption("c", function() -- UPX
	addPostProcess(function()
		winfo("Compacting... ")
		--io.popen("upx -9 "..arg[2],"r"):close()
		local status = os.execute("upx -9 "..arg[2].." > /dev/null")
		if (type(status) == "number" and status/256 == 0) or (type(status) == "boolean" and status == true) then
			print("Done.")
		else
			print("Error!")
		end
	end)
end, "Compact output using 'upx -9'")

addOption("n", function() -- No Check file
	nocheckfile = true
end, "Don't check the source file for syntax errors.")
-- Done

-- Modules from other files.
require("modules.luajit")
require("modules.ljx")
require("modules.llvmlua")
require("modules.macros")
require("modules.helloworld")
-- Done
options = getopt(optionlist)
for _,k in pairs(optionsequence) do
	if options[k] then
		optionstore[k]()
	end
end
if arg[1] ~= nil then
	if not file_exists(arg[1]) then
		fatal(string.format("Could not find file: %s", arg[1]))
	end
	if file_exists(arg[2]) then
		fatal("Output file exists, aborting..")
	end
end

if ((not (#arg >=2)) or options["h"]) then
	print("Usage: "..arg[0].." [-"..optionlist.."] file.lua output_binary [Extra_lua_files_or_Objects]")
	print("\t-h: Show this help.")
	for _,k in pairs(optionsequence) do
		if optioninfo[k] then
			print("\t-"..k..": "..tostring(optioninfo[k]))
		end
	end
	if options["h"] then
		os.exit(0)
	else
		os.exit(1)
	end
end
-- Done

-- Old Option parsing actions.
--[[
if options["s"] then
	-- Strip file
	table.insert(afterhooks, function()
		os.execute("strip --strip-all "..arg[2])
	end)
end

if options["u"] then
	-- UPX it!
	table.insert(afterhooks, function()
		os.execute("upx -9 "..arg[2])
	end)
end
]]
-- Done

if ccargs == "" then
	if os.getenv("luajit_src") then
		ccargs = ccargs .. "-I"..os.getenv("luajit_src")
	end
	if os.getenv("luajit_lib") then
		ccargs = "-l"..os.getenv("luajit_lib") .. " " .. ccargs
	end
	if os.getenv("luajit_obj") then
		ccargs = ccargs .. " " .. os.getenv("luajit_obj")
	end
	if not (os.getenv("luajit_obj") or os.getenv("luajit_lib")) then
		ccargs = "-lluajit-5.1 " .. ccargs
	end
end
if os.getenv("CFLAGS") then
	ccargs = ccargs .. " " .. os.getenv("CFLAGS")
end

-- Actual compilation.
buildObj = buildObj or buildObj_luajit
compile = compile or compile_luajit
if #preprocessors ~= 0 then
	pinfo("Preprocessing... ")
end
-- PreProcessing :o
local f, err = io.open(arg[1],"r")
if err then
	fatal(err)
end
luacode[arg[1]] = f:read("*all")
f:close()
for i=3, #arg, 1 do
	if arg[i]:match("%.lua$") then
		local f, err = io.open(arg[i],"r")
		if err then
			fatal(err)
		end
		luacode[arg[i]] = f:read("*all")
		f:close()
	end
end
for _,v in pairs(preprocessors) do
	luacode[arg[1]] = v(luacode[arg[1]], arg[1])
end
for i=3, #arg, 1 do
	for _,v in pairs(preprocessors) do
		luacode[arg[i]] = v(luacode[arg[i]], arg[i])
	end
end
-- Done.
winfo("Compiling: Phase one.. ")
buildObj(arg[1], arg[1], "main")
if #arg >= 3 then
	for i=3, #arg, 1 do
		if arg[i]:match("%.lua$") then
			table.insert(extra_objects, buildObj(arg[i],arg[i]))
		else
			table.insert(extra_objects,arg[i])
		end
	end
end
print("Done.")
winfo("Compiling: Phase Two... ")
local ret = compile(ccargs)
if type(ret) == "number" then
	if ret == 0 then
		print("Done.")
	else
		print("Error!")
	end
else
	print("Done.")
end
for k,v in pairs(posthooks) do
	v()
end
