# ljb [![Build Status](http://tty.sh:8090/buildStatus/icon?job=LJB&build=25)](http://tty.sh:8090/job/LJB/25/)
LJB: LuaJIT bundler/builder

# Usage:
```
Usage: ./ljb [-hqQmscnjxlt] file.lua output_binary [Extra_lua_files_or_Objects]
	-h: Show this help.
	-q: Quiet for the most part, excludes Errors.
	-m: Don't use colors.
	-s: Use -Os and strip output file using 'strip --strip-all'
	-c: Compact output using 'upx -9'
	-n: Don't check the source file for syntax errors.
	-j: Compile file with LuaJIT. [Default]
	-x: Compile file with LJX runtime instead of LuaJIT.
	-l: Compile file with LLVM-Lua.
	-t: Test 1 2 3! ^_^
```

# Building:
`$ lua build.lua`

Dependencies:
- gcc
- LuaJIT + Development headers.
- (Optional) LJX + development headers.
- (Optional) LLVM-Lua and clang.

# Running:
Running a compiled script requires no install of gcc, clang, LuaJIT, LJX or LLVM-Lua, if the script does not need it.

# License:
MIT
