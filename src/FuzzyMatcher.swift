//
//  FuzzyMatcher.swift
//  dmenu-mac
//
//  Created by Ivan on 17.06.23.
//  Copyright © 2023 Jose Pereira. All rights reserved.
//

import Foundation
import Darwin

func printHexDump(of pointer: UnsafeRawPointer, byteCount: Int) {
    print("hex dump of addr \(pointer):")

    pointer.withMemoryRebound(to: UInt8.self, capacity: byteCount) { bytePointer in
        let buffer = UnsafeBufferPointer(start: bytePointer, count: byteCount)
        
        for (index, byte) in buffer.enumerated() {
            print(String(format: " %02x", byte), terminator: "")
            
            // if (index + 1) % 8 == 0 {
            //     print(" ", terminator: "")
            // }
            
            if (index + 1) % 8 == 0 {
                print("")
            }
        }
        
        if buffer.count % 16 != 0 {
            print("")
        }
    }
}




// Matcher
class FuzzyMatcher {
    private var matcher: UnsafeMutableRawPointer?
    private var searchResultsPtr: Optional<UnsafeMutablePointer<SearchResults>>

    init() {
        self.matcher = matcher_new()
        self.searchResultsPtr = nil
    }

    deinit {
        // if let matcher = self.matcher {
        //     search_results_free(matcher)
        // }
    }

    func rescan() {
        matcher_rescan(matcher)
    }
    
    func search(pattern: String) -> [Item] {
        if let resultsPtr = searchResultsPtr {
            search_results_free(resultsPtr)
            self.searchResultsPtr = nil
        }
        
        let patternCString = pattern.cString(using: .utf8)
        let resultsPtr = matcher_search(matcher, patternCString)
        // printHexDump(of: resultsPtr!, byteCount: 128)
        // print("resultsPtr = \(resultsPtr)")
        let numItems = resultsPtr?.pointee.num_items ?? 0
        var items = [Item]()
        let pointee = resultsPtr?.pointee

        guard let pointee = pointee else { return [] }
        let items_ptr = pointee.items

        // print("items_ptr = \(items_ptr)")
        guard let items_ptr = items_ptr else { return [] }
        // printHexDump(of: items_ptr, byteCount: 128) // here it's correct

        // let as_size = malloc_size(items_ptr)
        // print("alloc_size of \(items_ptr) = \(as_size)")
        // let ptr_items = items_ptr.pointee
        // print("ptr_items = \(ptr_items)")
        
        let itemPointers = items_ptr
        // print("swift pointers: ")
        // print("hexdump2")
        // printHexDump(of: items_ptr, byteCount: 128)

        var citems: [UnsafeRawPointer] = [] //  Array([])
        // citems.reserveCapacity(512) // breaks just as well as adding 64 items


        for i in 0..<Int(numItems) {
            // if i > 1 {
            //     let i_ptr = withUnsafePointer(to: citems[0]) { $0 }
            //
            //     let address = UInt(bitPattern: i_ptr)
            //     print("Memory address of citems: 0x\(String(address, radix: 16))")
            // }
            let itemPointer = itemPointers + (8 * i)
            // let citem = itemPointer.pointee
            
            //print("\(i) itemPointer = \(itemPointer) citem = \(citem)")
            //citems.append(citem)
            if i == 64 {
                print("64")
            }
            
            citems.append(itemPointer)
            // if i == 0 || i == 63 || i == 64 {
            //     print("hexdump3: \(i)") // memory is rewritten at i= 64 // WTF?
            //     printHexDump(of: items_ptr, byteCount: 128)
            // }
        }
        // memory is rewritten between hexdumps 3 and 4
        // print("hexdump last")
        // printHexDump(of: items_ptr, byteCount: 128)
//
        // print("------------------------------")
        // print("------------------------------")
        // print("------------------------------")
        
        //for i in 0..<Int(numItems)-1 {
        //    // 1 * i because Swift already knows the size of a pointer //so it's actually 8
        //    let itemPointer = itemPointers + (1 * i)
        //    print("item pointer \(i) = \(itemPointer)")
        //    // let itemPtrInt = UInt(bitPattern: itemPointer)
            // let itemPtr2 = OpaquePointer(bitPattern: itemPtrInt)
            // let name2 = get_item_name(itemPtr2)
            // print("name2 = \(name2)")
            // let nameBlah = get_item_name(itemPointer.withMemoryRebound(to: Item.self, capacity: 1) { $0 }
//)
            //let citem = itemPointer.pointee
        var i = 0
        for citem in citems {
            // guard let citem = citem else { return [] }
            // print("citem = \(citem)")
            // let itemPointer = itemPointers[i]
            let item = Item(cItem: citem)
            let name = item.name
            // print("item name \(i) name = \(name)")
            items.append(item)
            i += 1
        }
        self.searchResultsPtr = resultsPtr
        // cannot free here because we still have the items
        // search_results_free(resultsPtr)
        
        return items
    }
}

// Item
class Item {
    private var item: UnsafeRawPointer
    
    init(cItem: UnsafeRawPointer) {
        let itemPtr = cItem.load(as: UnsafeRawPointer.self)

        self.item = itemPtr
    }

    var name: String? {
        // guard let item = self.item else {
        //     rejkturn nil
        // }

        let iptr = item
        // print("-> name item = \(item)")
        let itemName = get_item_name(item)
        let itemNameString = String(cString: itemName!)
        return itemNameString
    }
    
    func open() {
        // guard let item = self.item else {
        //     return
        // }

        item_open(item)

    }
}
