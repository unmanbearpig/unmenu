.PHONY: all clean fuzzylib mac-app

all: mac-app

fuzzylib:
	cargo build --release --manifest-path=fuzzylib/Cargo.toml
	cp fuzzylib/target/release/libfuzzylib.a mac-app/

mac-app: fuzzylib
	xcodebuild -project mac-app/unmenu.xcodeproj -scheme unmenu -derivedDataPath build -configuration Release build

install: mac-app
	cp -r mac-app/Build/Products/Release/unmenu.app /Applications/

clean:
	cd fuzzylib && cargo clean
	cd mac-app && rm -rf clean
