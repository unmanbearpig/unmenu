/*
 * Copyright (c) 2016 Jose Pereira <onaips@gmail.com>.
 * Copyright (c) 2024 Ivan <unmanbearpig@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import LaunchAtLogin
import Cocoa

// func log(_ message: String) {
//     let currentTime = Date()
//
//     let dateFormatter = DateFormatter()
//     dateFormatter.dateFormat = "HH:mm:ss.SSS"
//     let formattedTime = dateFormatter.string(from: currentTime)
//
//     let logMessage = "\(formattedTime) - \(message)"
//     print(logMessage)
// }

func log(_ message: String) {
    // let fileURL = URL(fileURLWithPath: "/Users/unmbp/unmenu.log")

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = formatter.string(from: Date())
    let logMessage = "[\(timestamp)] \(message)\n"

    // // Append the log message to the file
    // if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
    //     fileHandle.seekToEndOfFile()
    //     fileHandle.write(logMessage.data(using: .utf8)!)
    //     fileHandle.closeFile()
    // } else {
    //     try? logMessage.write(to: fileURL, atomically: true, encoding: .utf8)
    // }
    
    // Print the log message
    print(logMessage)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var startAtLaunch: NSMenuItem!

    var eventMonitor: Any?

    func doWeHavePermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        return accessEnabled
    }
    
    func showPermissionsSettings() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        return accessEnabled
    }
    
    func restartOurselves() {
        log("restarting...")
        
        // let path = (Bundle.main.resourcePath! as NSString).stringByDeletingLastPathComponent.stringByDeletingLastPathComponent
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        var newUrl = url.deletingLastPathComponent()
        newUrl = newUrl.deletingLastPathComponent()
        let path = newUrl.path
        
        log("path = \(path)")
        
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    
    func waitForPermissions() {
        let accessEnabled = doWeHavePermissions()
        if !accessEnabled {
            log("Access still not Enabled")
            // Delay the next iteration by 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                log("Retrying...")
                self.waitForPermissions()
            }
        } else {
            // we got the permissions
            let alert = NSAlert()
            alert.messageText = "Permissions granted"
            alert.informativeText = "App restart required to apply new permissions. After clicking Continue, use your designated hotkey or the default (cmd-ctrl-b) if unchanged."
            alert.addButton(withTitle: "Continue")
            alert.beginSheetModal(for: NSApp.windows.first!) { response in
                switch response {
                case .alertFirstButtonReturn:
                    self.restartOurselves()
                default:
                    return
                }
            }
        }
    }
    
    func setupHotkeyHandler() {
        let alert = NSAlert()
        
        if !doWeHavePermissions() {
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "To set up a global key handler, unmenu requires accessibility permissions. Please grant these permissions in the system settings."
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Quit unmenu")
            alert.beginSheetModal(for: NSApp.windows.first!) { response in
                switch response {
                case .alertFirstButtonReturn:
                    // show settings
                    let _ = self.showPermissionsSettings()
                    self.waitForPermissions()
                case .alertSecondButtonReturn:
                    // exit
                    log("User doesn't want to give us permissions")
                    NSApplication.shared.terminate(nil)
                default:
                    break
                }
            }
            
            log("Access Granted")
        }
        
        log("We already had permissions granted")
        
        var keyCode: UInt16 = 11
        var modifierFlags: UInt = 1310985 & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
          
        // Read config and hotkeys
        let fileManager = FileManager.default
        let homeDir = fileManager.homeDirectoryForCurrentUser
        let confPath = homeDir.appendingPathComponent(".config/unmenu/config.toml")
                
        if let config = Config(tomlFilePath: String(confPath.path)) {
            if let kc = config.hotkeyCode, let mf = config.hotkeyModifierFlags {
                print("Key Code: \(kc), Modifier Flags: \(mf)")
                keyCode = UInt16(kc)
                modifierFlags = UInt(mf)
            } else {
                print("Could not find hotkey configuration")
            }
        } else {
            print("Failed to load the config file.")
        }
        
        let eventMask = NSEvent.EventTypeMask.keyDown
        let eventHandler = { (event: NSEvent) -> Void in
            log("-- event handler")
            
            let devIndFlags = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            log("-> handler keycode = \(event.keyCode) flags = // \(event.modifierFlags.rawValue) dev_ind_flags = \(devIndFlags) win \(event.windowNumber) // \(event.window)")
            
            if event.keyCode == keyCode && devIndFlags == modifierFlags {
                log("   matched keycode = \(event.keyCode) flags = // \(event.modifierFlags.rawValue) win \(event.windowNumber) // \(event.window)")
                self.showAppWindow()
            }
        }

        self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask, handler: eventHandler)
    }

    func showAppWindow() {
        log("-> showAppWindow")
        
        NSApp.activate(ignoringOtherApps: true)
        let window = NSApp.windows.first
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("application did finish launching")
        
        let testkey1 = Keys.convertToKeyCodeAndModifierFlags(shortcut: "ctrl-cmd-b")
        log("testkey1 = \(testkey1)")
        
        if let testkey1 = testkey1 {
            var modifierFlags: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: testkey1.modifierFlags)
            
            // Check each modifier key and print if the flag is set
            if modifierFlags.contains(.capsLock) {
                print("Caps Lock is pressed")
            }
            if modifierFlags.contains(.shift) {
                print("Shift is pressed")
            }
            if modifierFlags.contains(.control) {
                print("Control is pressed")
            }
            if modifierFlags.contains(.option) {
                print("Option is pressed")
            }
            if modifierFlags.contains(.command) {
                print("Command is pressed")
            }
            if modifierFlags.contains(.numericPad) {
                print("Numeric Pad is pressed")
            }
            if modifierFlags.contains(.help) {
                print("Help is pressed")
            }
            if modifierFlags.contains(.function) {
                print("Function is pressed")
            }
        }

        
        let testkey2 = Keys.convertToKeyCodeAndModifierFlags(shortcut: "cmd-ctrl-b")
        log("testkey2 = \(testkey2)")
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "d"
        }

        self.setupHotkeyHandler()
        log("set up hotkey handler")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func toggleLaunchAtLogin() {
        let enabled = !LaunchAtLogin.isEnabled
        LaunchAtLogin.isEnabled = enabled
        startAtLaunch.state = enabled ? .on : .off
    }
}
