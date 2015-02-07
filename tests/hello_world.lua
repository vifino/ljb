print("Hello, World!")
print("Lua Version:",_VERSION)
if jit then
	print("LuaJIT Version:",jit.version)
print("Running on: ".. jit.os .. " " .. jit.arch)
end
