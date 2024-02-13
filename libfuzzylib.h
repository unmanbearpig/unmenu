//
//  libfuzzylib.h
//  dmenu-mac
//
//  Created by Ivan on 17.06.23.
//  Copyright © 2023 Jose Pereira. All rights reserved.
//

#ifndef libfuzzylib_h
#define libfuzzylib_h

// typedef struct Matcher Matcher;
// typedef struct Item Item;
typedef struct SearchResults SearchResults;

void* matcher_new();
void matcher_rescan(void* matcher);
SearchResults* matcher_search(void* matcher, const char* pattern);
void search_results_free(SearchResults* results);
// char* get_item_name(const Item* item);
char* get_item_name(const void *item);

void item_open(const void *item);

struct SearchResults {
    uint64_t num_items;
    const void* items;
};


#endif /* libfuzzylib_h */
