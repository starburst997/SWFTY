#!/bin/bash

# Compile hashlink for Mac
cd "$(dirname "$0")"

# Install hashlink dependencies
brew install libpng jpeg-turbo libvorbis sdl2 mbedtls openal-soft libuv

# Make install hashlink
cd submodules/hashlink
make all && make install
