.PHONY: all clean fuzzylib mac-app

all: mac-app

fuzzylib:
	cd fuzzylib && cargo build --release && cp target/release/libfuzzylib.a ../mac-app/

mac-app: fuzzylib
	cd mac-app && xcodebuild -project unmenu.xcodeproj -scheme unmenu -derivedDataPath ../build build

clean:
	cd fuzzylib && cargo clean
	cd mac-app && rm -rf clean
