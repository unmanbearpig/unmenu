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

func log(_ message: String) {
    let currentTime = Date()

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    let formattedTime = dateFormatter.string(from: currentTime)

    let logMessage = "\(formattedTime) - \(message)"
    print(logMessage)
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private var startAtLaunch: NSMenuItem!

    var eventMonitor: Any?

    func setupHotkeyHandler() {
        let eventMask = NSEvent.EventTypeMask.keyDown
        let eventHandler = { (event: NSEvent) -> Void in
            // why is it not being called when I launch it not form xcode?
            log("--- event handler")
            if event.keyCode == 11 && event.modifierFlags.rawValue == 1310985 {
                log("-> handler keycode = \(event.keyCode) flags = \(event.modifierFlags.rawValue) win \(event.windowNumber) \(event.window)")
                log("   got correct keycode, showing the window")
                self.showAppWindow()
            }
        }

        self.eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask, handler: eventHandler)
    }

    func showAppWindow() {
        log("-> showAppWindow")
        NSApp.activate(ignoringOtherApps: true)
        let window = NSApp.windows.first
        log("window = \(window)")
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
