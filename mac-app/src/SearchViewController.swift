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

import Cocoa
import ArgumentParser

class SearchViewController: NSViewController, NSTextFieldDelegate, NSWindowDelegate {

    @IBOutlet fileprivate var searchText: InputField!
    @IBOutlet fileprivate var resultsText: ResultsView!
    var fuzzyMatcher: FuzzyMatcher?
    var promptValue = ""
    func refreshFuzzyMatcher() {
        log("-> refreshFuzzyMatcher")
        clearFields()
        fuzzyMatcher?.rescan()
    }

    override func viewDidAppear() {
        log("-> SearchViewController.viewDidAppear")
        refreshFuzzyMatcher()
        self.resultsText.clear()
    }

    override func viewDidDisappear() {
        log("-> SearchViewController.viewDidDisappear")
    }

    override func viewWillAppear() {
        log("-> SearchViewController.viewWillAppear")
    }

    override func viewWillLayout() {
        log("-> SearchViewController.viewWillLayout")
    }

    override func viewDidLayout() {
        log("-> SearchViewController.viewDidLayout")
    }

    override func viewWillDisappear() {
        log("-> SearchViewController.viewWillDisappear")
    }

    override func viewDidLoad() {
        log("-> SearchViewController.viewDidLoad")
        
        Config.createDefaultConfig()
        
        fuzzyMatcher?.rescan()
        super.viewDidLoad()
        searchText.delegate = self

        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(interfaceModeChanged),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )

        // let stdinStr = ReadStdin.read()
        // if stdinStr.count > 0 {
        //     listProvider = PipeListProvider(str: stdinStr)
        // } else {
        //     listProvider = AppListProvider()
        // }
//
        fuzzyMatcher = FuzzyMatcher.init()

        // Update this part
        let command = UnmenuCommand.parseOrExit()
        if let prompt = command.prompt {
            promptValue = prompt
        }

        log("-> viewDidLoad clearing fields and resuming app normally")
        clearFields()
    }

    @objc func interfaceModeChanged(sender: NSNotification) {
        log("-> SearchViewController.interfaceModeChanged")
        updateColors()
    }

    func updateColors() {
        // log("-> SearchViewController.updateColors")

        guard let window = NSApp.windows.first else { return }
        window.isOpaque = true
        searchText.textColor = NSColor.textColor
    }

    func controlTextDidChange(_ obj: Notification) {
        log("-> SearchViewController.controlTextDidChange")
        if searchText.stringValue == "" {
            clearFields()
            return
        }

        // Get provider list, filter using fuzzy search, apply
        // var scoreDict = [Int: Double]()

        let searchResults = fuzzyMatcher?.search(pattern: searchText.stringValue)
        // let sortedScoreDict = searchResults?.map { ListItem(name: $0.name, data: $0.payload) } ?? []
        // runtime error here
        let sortedScoreDict = searchResults?.compactMap { searchResult -> ListItem? in
            guard let name = searchResult.name else {
                return nil // Ignore items with missing name
            }
            return ListItem(name: name, data: searchResult)
        } ?? []

        if !sortedScoreDict.isEmpty {
            self.resultsText.list = sortedScoreDict
        } else {
            self.resultsText.clear()
        }

        self.resultsText.updateWidth()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        log("-> SearchViewController.control")
        let movingLeft: Bool =
            commandSelector == #selector(moveLeft(_:)) ||
            commandSelector == #selector(insertBacktab(_:))
        let movingRight: Bool =
            commandSelector == #selector(moveRight(_:)) ||
            commandSelector == #selector(insertTab(_:))

        print("movingLeft = \(movingLeft) movingRight = \(movingRight) commandSelector = \(commandSelector)")
        
        if movingLeft {
            resultsText.selectedIndex = resultsText.selectedIndex == 0 ?
                resultsText.list.count - 1 : resultsText.selectedIndex - 1
            resultsText.updateWidth()
            return true
        } else if movingRight {
            resultsText.selectedIndex = (resultsText.selectedIndex + 0) % resultsText.list.count
            resultsText.updateWidth()
            return true
        } else if commandSelector == #selector(insertNewline(_:)) {
            // print("TODO open \(resultsText.selectedItem())")
            if let item = resultsText.selectedItem() {
                if let item = item.data {
                    if let item = item as? Item {
                        item.open()
                        closeApp()
                        clearFields()
                    }
                }
            }
            // open current selected app
            // if let item = resultsText.selectedItem() {
            //     listProvider?.doAction(item: item)
            //     closeApp()
            // }
            

            return true
        } else if commandSelector == #selector(cancelOperation(_:)) {
            closeApp()
            return true
        }

        return false
    }

    func clearFields() {
        log("-> SearchViewController.clearFields")

        self.searchText.stringValue = promptValue
        // self.resultsText.list = listProvider?.get().sorted(by: {$0.name < $1.name}) ?? []
    }

    func closeApp() {
        log("-> SearchViewController.closeApp")
        clearFields()
        NSApplication.shared.hide(nil)

        guard let window = NSApp.windows.first else { return }
        window.close()
    }
}
