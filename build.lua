-- Build script. Gone right :D
function run(cmd)
	print("$ "..cmd)
	os.execute(cmd)
end
run("luajit bin/ljb -smc bin/ljb modules/helloworld.lua")
print("Done.")
