#!/bin/zsh

# Compile fix on latest heaps
# -D hl_disable_mikkt

cd "$(dirname "$0")"

FILE=bin/SWFTY.hl

command_exists () {
    type "$1" &> /dev/null ;
}

rm -f $FILE

if command_exists haxe.exe ; then
    haxe.exe build-win.hxml --connect 6004 --times -v $@ # -dce full
    
    if [ -f $FILE ]; then
        hl.exe $FILE
    fi
else
    haxe build.hxml --connect 6004 --times -v $@ # -dce full

    if [ -f $FILE ]; then
        hl $FILE
    fi
fi