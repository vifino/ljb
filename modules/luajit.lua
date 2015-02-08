-- Compile file with LuaJIT. [Default]
function buildObj_luajit(infile, outfile, name)
	local dir, filename, extension = string.match(infile, "(.-)([^/]-([^%.]+))$")
	name = name or (dir:gsub("^%./",""):gsub("^/",""):gsub("/",".") .. filename:gsub("%.lua$",""))
	if not nocheckfile and infile then
		local file = assert(io.open(infile))
		local content = file:read("*all")
		file:close()
		local func,err = loadstring(content)
		if func then
			os.execute(string.format("%s -b -n "..name.." %s %s", ljbin, infile, outfile))
		else
			fatal(err)
		end
	else
		os.execute(string.format("%s -b -n "..name.." %s %s", ljbin, infile, outfile))
	end
end
function compile_luajit(fargs)
	local b = io.popen(string.format([[
	%s -O%s -Wall -Wl,-E \
		-x c %s -x none %s \
		%s \
		-o %s -lm -ldl -flto ]], (os.getenv("CC") or "gcc"), optimisationlevel, "-" ,(arg[1]..".o"), fargs.." ".. table.concat(extra_objects," "), arg[2]), "w")
	b:write(code)
	b:close()
	os.execute("rm -rf "..arg[1]..".o")
end
addOption("j",function()
	code = [[
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
	compiler = compile_luajit
	buildObj = buildObj_luajit
end, "Compile file with LuaJIT. [Default]")
