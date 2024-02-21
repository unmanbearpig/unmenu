/*
 * Copyright (c) 2020 Jose Pereira <onaips@gmail.com>.
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

import Foundation
import FileWatcher
import Cocoa


/**
 * Provide a list of launcheable apps for the OS
 */
class AppListProvider: ListProvider {

    var appDirDict = [String: Bool]()

    var appList = [URL]()

    init() {
        log("-> init")
        // let applicationDir = NSSearchPathForDirectoriesInDomains(
        //     .applicationDirectory, .localDomainMask, true)[0]
//
        // // Catalina moved default applications under a different mask.
        // let systemApplicationDir = NSSearchPathForDirectoriesInDomains(
        //     .applicationDirectory, .systemDomainMask, true)[0]
//
        // log("systemApplicationDir = \(systemApplicationDir)")
//
        // // appName to dir recursivity key/value dict
        // appDirDict[applicationDir] = true
        // appDirDict[systemApplicationDir] = true
        // appDirDict["/System/Applications/Utilities/"] = true
        // appDirDict["/System/Library/CoreServices/"] = false
        // let customDir = (FileManager.default.homeDirectoryForCurrentUser).appendingPathComponent(".unmenu-bin/").path
        // log("customDir = \(customDir)")
        // appDirDict[customDir] = true
//
        // initFileWatch(Array(appDirDict.keys))
        // updateAppList()
    }

    func initFileWatch(_ dirs: [String]) {
        let filewatcher = FileWatcher(dirs)
        filewatcher.callback = {_ in
            self.updateAppList()
        }
        filewatcher.start()
    }

    func get() -> [ListItem] {
        return appList.map({ListItem(name: $0.deletingPathExtension().lastPathComponent, data: $0)})
    }

    func updateAppList() {
        var newAppList = [URL]()
        appDirDict.keys.forEach { path in
            let urlPath = URL(fileURLWithPath: path, isDirectory: true)
            log("-----------------\npath = \(path) urlPath = \(urlPath)")

            let list = getAppList(urlPath, recursive: appDirDict[path]!)
            log("app list = \(list)\n-------------------------\n\n")
            newAppList.append(contentsOf: list)
        }
        appList = newAppList
    }

    func isDir(path: String) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }

    func getAppList(_ appDir: URL, recursive: Bool = true) -> [URL] {
        var list = [URL]()
        let fileManager = FileManager.default

        do {
            let subs = try fileManager.contentsOfDirectory(atPath: appDir.path)
            // TODO why can't we find Terminal.app in /System/Applications/Utilities ?
            for sub in subs {
                let dir = appDir.appendingPathComponent(sub)
                let isDirectory = isDir(path: dir.path)
                if isDirectory {
                    if dir.pathExtension == "app" {
                        list.append(dir)
                    }
                } else if FileManager.default.isExecutableFile(atPath: dir.path) {
                    list.append(dir)
                } else if dir.hasDirectoryPath && recursive {
                    list.append(contentsOf: self.getAppList(dir))
                } else {
                    log("found non-executable non-app \(dir)")
                }
            }
        } catch {
            log("Error on getAppList appDir = \(appDir), recursive = \(recursive)")
            NSLog("Error on getAppList: %@", error.localizedDescription)
        }
        return list
    }

    // TODO add support for arguments?
    func runExecutable(path: String) {
        let task = Process()
        task.launchPath = path // Path to your executable
        task.arguments = [] // Optional: Specify any arguments for your executable

       let outputPipe = Pipe()
       task.standardOutput = outputPipe
       task.launch()
    }

    func doAction(item: ListItem) {
        log("-> doAction \(item)")
        let app: URL = URL.init(fileURLWithPath: (item.data as? String)!)
        DispatchQueue.main.async {
            log("opening \(app)")

            if self.isDir(path: app.path) {
                log("running app")
                let conf = NSWorkspace.OpenConfiguration.init()
                conf.activates = true
                NSWorkspace.shared.openApplication(at: app, configuration: conf)
            } else {
                log("running executable file")
                self.runExecutable(path: app.path)
            }

            log("done\n")
        }
    }
}
