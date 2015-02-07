#ifndef __LUASOCKETSCRIPTS__
#define __LUASOCKETSCRIPTS__

#include <lua.h>

#ifndef LUAOPEN_API 
#define LUAOPEN_API 
#endif

LUAOPEN_API int luaopen_ftp(lua_State *L);
LUAOPEN_API int luaopen_headers(lua_State *L);
LUAOPEN_API int luaopen_http(lua_State *L);
LUAOPEN_API int luaopen_ltn12(lua_State *L);
LUAOPEN_API int luaopen_mbox(lua_State *L);
LUAOPEN_API int luaopen_mime(lua_State *L);
LUAOPEN_API int luaopen_smtp(lua_State *L);
LUAOPEN_API int luaopen_socket(lua_State *L);
LUAOPEN_API int luaopen_tp(lua_State *L);
LUAOPEN_API int luaopen_url(lua_State *L);

#endif /* __LUASOCKETSCRIPTS__ */
