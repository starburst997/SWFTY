#!/bin/bash

cd "$(dirname "$0")"

haxelib install hashlink
haxelib install hscript

haxelib dev swfty .

cd submodules
haxelib dev format format
haxelib dev haxe-file-save haxe-file-save
haxelib dev haxe-file-load haxe-file-load
haxelib dev haxe-zip haxe-zip
haxelib dev haxe-custom haxe-custom
haxelib dev haxe-concurrent haxe-concurrent
haxelib dev haxe-files haxe-files
haxelib dev haxe-strings haxe-strings
haxelib dev haxe-ws haxe-ws
haxelib dev console.hx console.hx
haxelib dev hxp hxp
haxelib dev lime lime
haxelib dev openfl openfl
haxelib dev hxbit hxbit
haxelib dev binpacking Rectangle-Bin-Packing
haxelib dev mcli mcli
haxelib dev hxcpp hxcpp
haxelib dev heaps heaps
haxelib dev tilelayer tilelayer/haxelib
haxelib dev tweenxcore tweenx/src/tweenxcore
haxelib dev hlsdl hashlink/libs/sdl
haxelib dev hlopenal hashlink/libs/openal

# Install hashlink dependencies
brew install libpng jpeg-turbo libvorbis sdl2 mbedtls openal-soft libuv

# Make install hashlink
cd hashlink
make all && make install
