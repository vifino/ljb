LUAJIT?=luajit

all: ljb
clean:
	rm ljb

ljb: bin/ljb.lua
	$(LUAJIT) bin/ljb.lua -sNmc bin/ljb.lua $@ modules/*.lua
