#!/usr/bin/env lua
-- Build script. Gone right :D
function run(cmd)
	print("$ "..cmd)
	os.execute(cmd)
end
run("luajit bin/ljb.lua -smc bin/ljb.lua ljb modules/*.lua")
print("Done.")
