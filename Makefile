all: ljb
clean:
	rm ljb
ljb:
	luajit bin/ljb.lua -sNmc bin/ljb.lua ljb modules/*.lua
