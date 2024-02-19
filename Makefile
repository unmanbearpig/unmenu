.PHONY: all clean fuzzylib mac-app

all: mac-app

fuzzylib:
	cd fuzzylib && cargo build --release && cp target/release/libfuzzylib.a ../mac-app/

mac-app: fuzzylib
	# not sure if we need build at the end
	cd mac-app && xcodebuild -project dmenu-unmacbp.xcodeproj -scheme dmenu-unmacbp -derivedDataPath ../build build

clean:
	cd fuzzylib && cargo clean
	cd mac-app && rm -rf clean
