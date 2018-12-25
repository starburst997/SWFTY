#!/bin/sh

cd "$(dirname "$0")"

command_exists () {
    type "$1" &> /dev/null ;
}

FILE=bin/SWFTY.js

rm -f $FILE

if command_exists haxe.exe ; then
    haxe.exe html5.hxml --times $@ # -dce full --connect 6003
else
    haxe html5.hxml --times --connect 6004 $@ # -dce full
fi