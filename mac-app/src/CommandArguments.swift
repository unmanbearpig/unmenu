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

import ArgumentParser

struct UnmenuCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "unmenu",
        abstract: "A quick launcher for macOS"
    )

    @Option(name: .shortAndLong, help: "Show a prompt instead of the search input.")
    var prompt: String?

    // We don't need a run() method if we're just parsing arguments
}