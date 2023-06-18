
# dmenu-mac


dmenu inspired application launcher.

![dmenu-mac demo](./demo.gif)

## About this fork

- Fixed (hopefully) random desktop switching when you hit the hotkey to spawn the app
- Removed dependency on "Settings" library, now the hotkey is hardcoded to cmd-ctrl-x
- Use https://crates.io/crates/fuzzy-matcher for matching, I find its behavior more intuitive
- Allow to run scripts and non-app executables
- You can put scripts to be run from this app to ~/.dmenu-bin/, can be a bash script or any kind of executable, just make sure to set "chmod +x" on the files you want to be able to run

## Who is it for
Anyone that needs a quick and intuitive keyboard-only application launcher that does not rely on spotlight indexing.

## Why
If you are like me and have a shit-ton of files on your computer, and spotlight keeps your CPU running like crazy.

1. [Disable spotlight](https://www.google.com/search?q=disable+spotlight+completely) completely and its global shortcut (recommended but not necessary)
3. Download and run dmenu-mac

## How to use
1. Open the app, use cmd-Space to bring it to front.
2. Optionally, you can change the binding by clicking the ... on the right of the menu.
3. Type the application you want to open, hit enter to run the one selected.

### Pipes

I don't care about pipes from original app,
so I don't even know if they work in this fork

## Building

- Make sure you have Rust installed
- Check out https://github.com/unmanbearpig/fuzzylib to the parent directory
- run ./build.sh

## Features

- Uses fuzzy search
- Configurable global hotkey
- Multi-display support
- Not dependant on spotlight indexing

# Pull requests
Any improvement/bugfix is welcome.

# Authors

[@onaips - original author](https://twitter.com/onaips)
[@unmanbearpig - this fork](https://unmb.pw)
