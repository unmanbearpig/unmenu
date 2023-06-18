//
//  Matcher.swift
//  dmenu-mac
//
//  Created by Ivan on 17.06.23.
//  Copyright © 2023 Ivan Fedyunin. All rights reserved.
//

import Foundation

// Define C API functions
typealias CMatcher = UnsafeMutableRawPointer
typealias CSearchResult = UnsafeMutablePointer<CChar>

func matcher_add(_ matcher: CMatcher, _ itemName: String, itemPayload: String) {
    let citemName = strdup(itemName)
    let citemPayload = strdup(itemPayload)

    matcher_add(matcher, itemName, itemPayload)
    free(citemName)
    free(citemPayload)
}

func matcher_search(_ matcher: CMatcher, _ pattern: String) -> [SearchResult] {
    pattern.withCString { cPattern in
        let searchResults = matcher_search(matcher, cPattern)
        if searchResults == nil {
            return []
        }
        var results: [SearchResult] = []
        var index: Int32 = 0
        while true {
            // let sr = searchResults[index]
            if search_result_is_null(searchResults, index) != 0 {
                break
            }
            let name: String = String.init(cString: search_result_item_name(searchResults, index))
            let payload: String = String.init(cString: search_result_item_payload(searchResults, index))
            let score = search_result_score(searchResults, index)
            let sr = SearchResult(score: score, name: name, payload: payload)
        }
        search_result_free(searchResults)
        return results
    }
}
