#!/bin/bash
# A bloody command line.
# I should automate this..

env CC="gcc -I/home/vifino/code/luasocket/src" \
ljb_cadd="luapreload_fullluasocket(L);" \
ljb_cpre="#include \"luasocketscripts.h\"\n#include \"fullluasocket.h\"" \
ljb socket.lua sockettest luasocketscripts.c fullluasocket.c
