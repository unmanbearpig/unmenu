/*
 * Copyright (c) 2020 Jose Pereira <onaips@gmail.com>.
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
import Fuse
import Cocoa


/**
 * Provide a list of launcheable apps for the OS
 */
class AppListProvider: ListProvider {

    var appDirDict = [String: Bool]()

    var appList = [URL]()

    init() {
        log("-> init")
        let applicationDir = NSSearchPathForDirectoriesInDomains(
            .applicationDirectory, .localDomainMask, true)[0]

        // Catalina moved default applications under a different mask.
        let systemApplicationDir = NSSearchPathForDirectoriesInDomains(
            .applicationDirectory, .systemDomainMask, true)[0]

        // appName to dir recursivity key/value dict
        appDirDict[applicationDir] = true
        appDirDict[systemApplicationDir] = true
        appDirDict["/System/Library/CoreServices/"] = false
        let customDir = (FileManager.default.homeDirectoryForCurrentUser).appendingPathComponent(".dmenu-bin/").path
        log("customDir = \(customDir)")
        appDirDict[customDir] = true

        initFileWatch(Array(appDirDict.keys))
        updateAppList()
    }

    func initFileWatch(_ dirs: [String]) {
        let filewatcher = FileWatcher(dirs)
        filewatcher.callback = {_ in
            self.updateAppList()
        }
        filewatcher.start()
    }

    func updateAppList() {
        var newAppList = [URL]()
        appDirDict.keys.forEach { path in
            let urlPath = URL(fileURLWithPath: path, isDirectory: true)
            let list = getAppList(urlPath, recursive: appDirDict[path]!)
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

            for sub in subs {
                let dir = appDir.appendingPathComponent(sub)

                let isDirectory = isDir(path: dir.path)
                if isDirectory {
                    log("found directory \(dir)")
                    if dir.pathExtension == "app" {
                        log("directory is an app \(dir)")
                        list.append(dir)
                    }
                } else if FileManager.default.isExecutableFile(atPath: dir.path) {
                    log("found executable \(dir)")
                    list.append(dir)
                } else if dir.hasDirectoryPath && recursive {
                    list.append(contentsOf: self.getAppList(dir))
                } else {
                    log("found non-executable non-app \(dir)")
                }
            }
        } catch {
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

       // We don't need to do that, right?
       // task.waitUntilExit()

       // let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
       // if let outputString = String(data: outputData, encoding: .utf8) {
       //     print(outputString)
       // }
    }

    func doAction(item: ListItem) {
        guard let app: URL = item.data as? URL else {
            log("Cannot do action on item \(item.name)")
            return
        }
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
