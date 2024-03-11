# unmenu

This repository is a fork of dmenu-mac (https://github.com/oNaiPs/dmenu-mac), enhancing its functionality and addressing certain issues.

### Changes and New Features

- Fixed a longstanding issue https://github.com/oNaiPs/dmenu-mac/issues/41
- Switched to Accessibility API for handling hotkeys because it seems to work well

- Implemented what I believe to be a superior fuzzy matching algorithm, leveraging https://crates.io/crates/fuzzy-matcher

- Introduced a configuration file located at ~/.config/unmenu/config, enabling users to customize search directories, filter out applications and integrate scripts and aliases

# Installation

If you use the [Homebrew](https://brew.sh/) package manager on macOS, you can easily install unmenu:

```sh
brew install unmenu
```

# Building

1. Build fuzzylib
This step requires Rust installed

```
cd fuzzylib
cargo build --release
cp target/release/libfuzzylib.a ../mac-app/
```

2. Build macOS application:
Requires Xcode

 - open mac-app/unmenu.xcodeproj
 - Click the menu item Product -> Archive
 - Right click on the archive called `unmenu` and `Show in Finder`
 - Right click on it in Finder and `Show Package`, Products -> Applications
 - Copy unmenu.app to /Applications

# Getting started

1. Launch the app
2. Follow instructions to enable permissions
3. Hit Ctrl-Cmd-b by deafult
4. Customize settings by editing ~/.config/unmenu/config.toml according to your preferences

# Scripts / Aliases

Users can incorporate various scripts and aliases into unmenu for extended functionality.

1. Set up a directory to store your scripts
2. Add your scripts with appropriate shebangs, and ensure they are executable (chmod +x).
3. Include the script directory in the `dirs` variable within the configuration.
4. Ensure that `find_executables` is set to true in the config file

After these steps, you can execute scripts directly from unmenu by invoking their names via unmenu. This allows for the addition of aliases or any desired custom functionality.

# Authors

[@onaips - Original Author](https://twitter.com/onaips)
[@unmanbearpig - Author of this fork](https://unmb.pw)
