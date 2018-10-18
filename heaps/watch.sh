#!/bin/sh

cd "$(dirname "$0")"

command_exists () {
    type "$1" &> /dev/null ;
}

FILE=bin/SWFTY.js

live-server bin