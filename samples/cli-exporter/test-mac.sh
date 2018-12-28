#!/bin/bash

# cd to the script's directory so we can run it from anywhere
cd "$(dirname "$0")"

rm -Rf ./bin/macos/bin/SWFTY.app

openfl build mac -final -v

FILE=bin/macos/bin/SWFTY.app/Contents/MacOS/SWFTY
if [ -f $FILE ]; then
    ./$FILE $@ -r $PWD/../../
else
    echo "File not found"
fi