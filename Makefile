.PHONY: all clean fuzzylib mac-app

all: mac-app

fuzzylib:
	cd fuzzylib && cargo build --release && cp target/release/libfuzzylib.a ../mac-app/

mac-app: fuzzylib
	# not sure if we need build at the end
	cd mac-app && SYMROOT=symroot xcodebuild -project dmenu-unmacbp.xcodeproj -scheme dmenu-unmacbp -configuration Release # build

clean:
	cd fuzzylib && cargo clean
	cd mac-app && xcodebuild -project dmenu-unmacbp.xcodeproj clean
