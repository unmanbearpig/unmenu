//
//  Config.swift
//  unmenu
//
//  Copyright © 2024 Ivan <unmanbearpig@gmail.com>. All rights reserved.
//  Copyright © 2024 Jose Pereira. All rights reserved.
//

import Foundation
import TOMLDecoder
import Cocoa

class Config {
    var hotkeyCode: UInt16?
    var hotkeyModifierFlags: UInt?
    
    // Define the structure of your TOML config file, making each property optional.
    struct Conf: Codable {
        var hotkey: Hotkey?

        struct Hotkey: Codable {
            // Meaning it's the same physical key as on qwerty layout, regardless of current layout
            // So it's not gonna match dvorak keys for example
            var qwerty_hotkey: String?
            var key_code: UInt16?
            var modifier_flags: UInt16?
        }
    }

    // The initializer that takes the path of the TOML file.
    init?(tomlFilePath: String) {
        do {
            // let content = try String(contentsOfFile: tomlFilePath)
            let tomlData = try Data(contentsOf: URL(fileURLWithPath: tomlFilePath))

            parseConfig(tomlData: tomlData)
        } catch {
            print("Error reading TOML file: \(error)")
            return nil
        }
    }

    // A simple parser for the given TOML content.
    private func parseConfig(tomlData: Data) {
        do {
            // Read the content into data.
            // let tomlData = try Data(contentsOf: URL(fileURLWithPath: tomlFilePath))

            // Create an instance of the TOMLDecoder and decode the file.
            let decoder = TOMLDecoder()
            let config = try decoder.decode(Conf.self, from: tomlData)

            // Access the optional properties safely with optional binding.
            if let hotkeyConfig = config.hotkey {
                if let keyCode = hotkeyConfig.key_code, let modifierFlags = hotkeyConfig.modifier_flags {
                    print("Key Code: \(keyCode), Modifier Flags: \(modifierFlags)")
                } else {
                    if let hotkey = hotkeyConfig.qwerty_hotkey {
                        if let (keyCode, modifierFlags) = Keys.convertToKeyCodeAndModifierFlags(shortcut: hotkey) {
                            
                            self.hotkeyCode = keyCode
                            self.hotkeyModifierFlags = modifierFlags
                        }
                            
                    } else {
                        print("Hotkey properties are not fully defined in TOML file.")
                    }
                }
            } else {
                print("No hotkey configuration found in TOML file.")
            }

        } catch {
            print("Failed to read or decode the TOML file: \(error)")
        }

    }
}

