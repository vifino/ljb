#include <lua.h>
#include <lauxlib.h>

#include "luasocket.h"
#include "luasocketscripts.h"
#include "fullluasocket.h"

LUAPRELOAD_API int luapreload_fullluasocket(lua_State *L) {
	luaL_findtable(L, LUA_GLOBALSINDEX, "package.preload", 2);
	
	lua_pushcfunction(L, luaopen_socket_core);
	lua_setfield(L, -2, "socket.core");
	lua_pushcfunction(L, luaopen_ftp);
	lua_setfield(L, -2, "ftp");
	lua_pushcfunction(L, luaopen_headers);
	lua_setfield(L, -2, "headers");
	lua_pushcfunction(L, luaopen_http);
	lua_setfield(L, -2, "http");
	lua_pushcfunction(L, luaopen_ltn12);
	lua_setfield(L, -2, "ltn12");
	lua_pushcfunction(L, luaopen_mbox);
	lua_setfield(L, -2, "mbox");
	lua_pushcfunction(L, luaopen_mime);
	lua_setfield(L, -2, "mime");
	lua_pushcfunction(L, luaopen_smtp);
	lua_setfield(L, -2, "smtp");
	lua_pushcfunction(L, luaopen_socket);
	lua_setfield(L, -2, "socket");
	lua_pushcfunction(L, luaopen_tp);
	lua_setfield(L, -2, "tp");
	lua_pushcfunction(L, luaopen_url);
	lua_setfield(L, -2, "url");
	
	lua_pop(L, 1);
	return 0;
}
