-- Compile file with LJX runtime, not luajit.
addOption("x",function()
	extra_c = os.getenv("ljb_cadd") or ""
	code = [[
#include <stdio.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

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
	ljbin = os.getenv("ljx_bin") or "ljx"
	if os.getenv("ljx_src") then
		args = args .. "-I"..os.getenv("ljx_src")
	end
	if os.getenv("ljx_lib") then
		args = "-l"..os.getenv("ljx_lib") .. " " .. args
	end
	if os.getenv("ljx_obj") then
		args = args .. " " .. os.getenv("ljx_obj")
	end
	if not (os.getenv("ljx_obj") or os.getenv("ljx_lib")) then
		args = "-lluajit-ljx " .. args
	end
end, "Compile file with LJX runtime instead of LuaJIT.")
