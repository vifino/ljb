local mp = require "luajit-msgpack-pure"
local my_data = {this = {"is",4,"test"}}
local encoded = mp.pack(my_data)
local offset,decoded = mp.unpack(encoded)
assert(offset == #encoded)
