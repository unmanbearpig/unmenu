#!/bin/sh

set -e

echo "building fuzzylib"
cd ../fuzzylib
cargo build --release

echo "copying fuzzylib to dmenu-mac"
cp target/release/libfuzzylib.dylib ../dmenu-mac/

echo "building dmenu-mac"
cd ../dmenu-mac
xcodebuild -workspace dmenu-mac.xcodeproj/project.xcworkspace -scheme dmenu-mac
