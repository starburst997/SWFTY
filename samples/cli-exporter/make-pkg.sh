#!/bin/bash

mkdir bin
mkdir bin/mac-installer

pkgbuild --root bin/macos/bin/SWFTY.app --identifier jd.boivin.swfty --scripts scripts/mac --install-location /Applications/SWFTY.app bin/mac-installer/SWFTY.pkg --sign "Developer ID Installer: Jean-Denis Boivin (P7K4SUSDX6)"