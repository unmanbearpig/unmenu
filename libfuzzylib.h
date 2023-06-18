//
//  libfuzzylib.h
//  dmenu-mac
//
//  Created by Ivan on 17.06.23.
//  Copyright © 2023 Jose Pereira. All rights reserved.
//

#ifndef libfuzzylib_h
#define libfuzzylib_h

void* matcher_new();
// 81 pub unsafe extern "C" fn matcher_add(matcher_ptr: *mut CMatcher, item_name: *const c_char, item_payload: *const c_char) {

void matcher_add(void* matcher, const char* item_name, const char* item_payload);
void matcher_free(void* matcher);
void* matcher_search(const void* matcher, const char* pattern);
void matcher_clear(void* matcher);
void search_result_free(void* results);
const char* search_result_item_name(const void* results, int index);
const char* search_result_item_payload(const void* results, int index);
int8_t search_result_is_null(const void* result, int index);
int64_t search_result_score(const void* results, int index);

int search_result_count(const void* results);


#endif /* libfuzzylib_h */
