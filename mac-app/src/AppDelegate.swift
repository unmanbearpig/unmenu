/*
 * Copyright (c) 2016 Jose Pereira <onaips@gmail.com>.
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
    let fileURL = URL(fileURLWithPath: "/Users/ivan/dmenu-mac.log")

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = formatter.string(from: Date())
    let logMessage = "[\(timestamp)] \(message)\n"
    
    // Append the log message to the file
    if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
        fileHandle.seekToEndOfFile()
        fileHandle.write(logMessage.data(using: .utf8)!)
        fileHandle.closeFile()
    } else {
        try? logMessage.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    // Print the log message
    print(logMessage)
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var startAtLaunch: NSMenuItem!

    var eventMonitor: Any?

    func showAlert() {
        let alert = NSAlert()
        alert.messageText = "Alert"
        alert.informativeText = "This is an example alert."
        alert.addButton(withTitle: "OK")
        
        let modalResult = alert.runModal()
        
        if modalResult == NSApplication.ModalResponse.alertFirstButtonReturn {
            // Handle the user's response when OK is clicked
            print("OK clicked")
        }
    }
    
    func waitForPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
           log("Access Not Enabled")
            // Delay the next iteration by 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                log("Retrying...")
                self.waitForPermissions()
            }
        } else {
           log("Access Granted")
            let eventMask = NSEvent.EventTypeMask.keyDown
            let eventHandler = { (event: NSEvent) -> Void in
                log("--- event handler")
                if event.keyCode == 11 && event.modifierFlags.rawValue == 1310985 {
                    log("-> handler keycode = \(event.keyCode) flags = // \(event.modifierFlags.rawValue) win \(event.windowNumber) // \(event.window)")
                    log("   got correct keycode, showing the window")
                    self.showAppWindow()
                }
            }

            self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask, handler: eventHandler)

        }
    }
    
    func setupHotkeyHandler() {
        waitForPermissions()
    }

    func showAppWindow() {
        log("-> showAppWindow")
        NSApp.activate(ignoringOtherApps: true)
        let window = NSApp.windows.first
        // log("window = \(window)")
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("application did finish launching")

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
