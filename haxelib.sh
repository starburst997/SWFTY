#!/bin/bash

rm -Rf temp
mkdir temp

rsync -av --exclude='**/exporter/*' src temp
cp haxelib.json temp/haxelib.json
cp include.xml temp/include.xml

mkdir bin
cd temp
find . -type d -empty -delete
zip -r -X "../bin/haxelib.zip" *
cd ..
rm -Rf temp