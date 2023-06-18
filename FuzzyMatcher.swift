//
//  FuzzyMatcher.swift
//  dmenu-mac
//
//  Created by Ivan on 17.06.23.
//  Copyright © 2023 Jose Pereira. All rights reserved.
//

import Foundation

public class FuzzyMatcher {
    private var matcherPtr: Optional<UnsafeMutableRawPointer>!

    public init() {
        matcherPtr = matcher_new()
    }

    deinit {
        matcher_free(matcherPtr)
    }

    public func add(_ name: String, path: URL) {
        let cName = (name as NSString).utf8String
        let cPayload = (path.path as NSString).utf8String
        matcher_add(matcherPtr, cName, cPayload)
    }

    public func search(_ pattern: String) -> [SearchResult] {
        log("-> search pattern = \(pattern)")
        // let cPattern = pattern.withCString { $0 }
        let cPattern = (pattern as NSString).utf8String
        let searchResultsPtr = matcher_search(matcherPtr, cPattern)
        if searchResultsPtr == nil {
            log("!! search results is nil")
            return []
        }
        let count = search_result_count(searchResultsPtr)
        var searchResults: [SearchResult] = []
        for i in 0..<count {
            // let itemPtr = search_result_item(searchResultsPtr, Int32(i))!
            let name = String(cString: search_result_item_name(searchResultsPtr, Int32(i)))
            let payload = String(cString: search_result_item_payload(searchResultsPtr, Int32(i)))
            let score = search_result_score(searchResultsPtr, Int32(i))
            let result = SearchResult(score: score, name: name, payload: payload)
            searchResults.append(result)
        }
        search_result_free(searchResultsPtr)
        return searchResults
    }

    public func clear() {
        matcher_clear(matcherPtr)
    }
}

public struct SearchResult {
    public var score: Int64
    public var name: String
    public var payload: String
}
