use fuzzy_matcher::skim::SkimMatcherV2;
use fuzzy_matcher::FuzzyMatcher;

use std::ffi::{CString, CStr, c_char, c_int};

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Item {
    name: String,
    payload: String,
}

#[derive(Default)]
pub struct Matcher {
    matcher: SkimMatcherV2,
    items: Vec<Item>
}

impl Matcher {
    pub fn add(&mut self, item: Item) {
        self.items.push(item);
    }

    pub fn search(&self, pattern: &str) -> Vec<(i64, &Item)> {
        let mut result: Vec<(i64, &Item)> = Vec::new();
        for item in &self.items {
            if let Some(score) = self.matcher.fuzzy_match(&item.name, pattern) {
                result.push((score, item))
            }
        }
        result.sort_by_key(|(k, _)| -*k);
        result
    }

    pub fn clear(&mut self) {
        self.items.clear()
    }
}


// C API

#[repr(C)]
pub struct CMatcher {
    matcher: Matcher,
}

#[repr(C)]
pub struct CItem {
    name: *const c_char,
    payload: *const c_char,
}

impl CItem {
    fn from_item(item: &Item) -> CItem {
        CItem {
            name: CString::new(item.name.clone()).expect("CString new err for name").into_raw(),
            payload: CString::new(item.payload.clone()).expect("CString new err for payload").into_raw(),
        }
    }
}

#[no_mangle]
pub extern "C" fn matcher_new() -> *mut CMatcher {
    // println!("-> matcher_new");
    Box::into_raw(Box::new(CMatcher {
        matcher: Matcher::default(),
    }))
}

#[no_mangle]
pub extern "C" fn matcher_free(matcher_ptr: *mut CMatcher) {
    // println!("-> matcher_free");
    if !matcher_ptr.is_null() {
        unsafe {
            Box::from_raw(matcher_ptr);
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn matcher_add(matcher_ptr: *mut CMatcher, item_name: *const c_char, item_payload: *const c_char) {
    // println!("-> matcher_add");
    unsafe {
        let item_name = CStr::from_ptr(item_name).to_str();
        if let Err(e) = item_name {
            // println!("item_name error: {e:?}");
            return;
        }
        let item_name = item_name.unwrap();

        let item_payload = CStr::from_ptr(item_payload).to_str();
        if let Err(e) = item_payload {
            // println!("item_payload error: {e:?}");
            return;
        }
        let item_payload = item_payload.unwrap();

        let item = Item {
            name: item_name.to_string(),
            payload: item_payload.to_string(),
        };

        (*matcher_ptr).matcher.add(item);
    }
}

#[no_mangle]
pub unsafe extern "C" fn matcher_search(matcher_ptr: *const CMatcher, pattern: *const c_char) -> *mut CSearchResult {
    // println!("-> matcher_search, pattern ptr = {:#01x}", pattern as usize);

    let mut ii = 0usize;
    print!("pattern chars = ");
    loop {
        let c: *const c_char = (pattern as usize + ii) as *const c_char;
        if *c == 0 { break; }
        print!("{:#02} ", *c as u8);
        ii += 1;
    }
    // println!("end of chars");

    unsafe {
        // println!("total num items = {}", (*matcher_ptr).matcher.items.len());

        let c_str = CStr::from_ptr(pattern);

        let pattern_str = c_str.to_str();
        if let Err(e) = pattern_str {
            // println!("cannot convert cstr to str: {e:?}");
            return 0 as *mut CSearchResult;
        }
        let pattern_str = pattern_str.unwrap();

        // println!("got pattern: \"{pattern_str}\"");
        let results = (*matcher_ptr).matcher.search(pattern_str);
        // println!("got {} results", results.len());
        // println!("results: {results:?}");
        if results.is_empty() {
            // println!("returning 0 beacuse no results");
            return 0 as *mut CSearchResult;
        }
        let mut result_vec: Vec<CSearchResult> = Vec::new();

        for (score, item) in results {
            let item = CItem::from_item(item);
            let search_result = CSearchResult { score, item };
            // let c_item = CString::new(item).expect("CString::new failed");
            // let search_result = SearchResult {
            //     score,
            //     item: c_item.into_raw(),
            // };
            result_vec.push(search_result);
        }
        // terminate the array
        result_vec.push(CSearchResult {
            item: CItem { name: (0 as *const c_char),
            payload: (0 as *const c_char) },
            score: 0
        });

        let result_ptr = result_vec.as_mut_ptr();
        let val: usize = result_ptr as usize;
        // println!("result_ptr = {val}");
        std::mem::forget(result_vec);
        return result_ptr;
    }
}

#[no_mangle]
pub unsafe extern "C" fn matcher_clear(matcher_ptr: *mut CMatcher) {
    unsafe {
        (*matcher_ptr).matcher.clear();
    }
}

#[derive(Eq, PartialEq)]
pub struct SearchResult {
    score: i64,
    item: *const c_char,
}

#[repr(C)]
pub struct CSearchResult {
    score: i64,
    item: CItem,
}

#[no_mangle]
pub extern "C" fn search_result_count(results: *const CSearchResult) -> c_int {
    let mut count = 0;
    let mut ptr = results;
    unsafe {
        while !(*ptr).item.name.is_null() {
            count += 1;
            ptr = ptr.add(1);
        }
    }
    count
}

#[no_mangle]
pub unsafe extern "C" fn search_result_item_name(results: *const CSearchResult, index: c_int) -> *const c_char {
    unsafe {
        let result = &*results.offset(index as isize);
        result.item.name
    }
}

#[no_mangle]
pub unsafe extern "C" fn search_result_item_payload(results: *const CSearchResult, index: c_int) -> *const c_char {
    unsafe {
        let result = &*results.offset(index as isize);
        result.item.payload
    }
}

#[no_mangle]
pub unsafe extern "C" fn search_result_is_null(results: *const CSearchResult, index: c_int) -> u8 {
    let result = &*results.offset(index as isize);
    unsafe {
        if (*result).item.name == std::ptr::null() {
            1
        } else {
            0
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn search_result_score(results: *const CSearchResult, index: c_int) -> i64 {
    unsafe {
        let result = &*results.offset(index as isize);
        result.score
    }
}

#[no_mangle]
pub unsafe extern "C" fn search_result_free(results: *mut CSearchResult) {
    // println!("-> search_result_free {:#01}", results as usize);
    unsafe {
        if !results.is_null() {
            let mut count = 0;
            let mut ptr = results;
            while search_result_is_null(ptr, 0) != 0 {
                let _ = CString::from_raw((*ptr).item.name as *mut c_char);
                let _ = CString::from_raw((*ptr).item.payload as *mut c_char);
                count += 1;
                ptr = ptr.add(1);
            }
            std::ptr::drop_in_place(
                std::slice::from_raw_parts_mut(results, count));
        }
    }
}


// #[no_mangle]
// pub extern "C" fn new_matcher() -> *mut c_void {
//     let matcher = Box::new(Matcher::default());
//     unsafe {
//         return std::mem::transmute(Box::into_raw(matcher));
//     }
// }
// 
// #[no_mangle]
// pub extern "C" fn add_to_matcher(matcher: *mut c_void, item: *const i8) {
//     unsafe {
//         let item = CStr::from_ptr(item);
//         let matcher: *mut Matcher = std::mem::transmute(matcher);
//         let item = (*item).to_string_lossy();
//         (*matcher).add(item.to_string());
//     }
// }
// 
// #[repr(C)]
// pub struct MatchResult {
//     score: i64,
//     item: *const u8,
// }
// 
// #[no_mangle]
// pub extern "C" fn search_matcher(matcher: *const c_void, pattern: *const i8) -> *mut MatchResult {
//     unsafe {
//         let pattern = CStr::from_ptr(pattern);
//         let matcher: *mut Matcher = std::mem::transmute(matcher);
//         let pattern = (*pattern).to_string_lossy();
//         let result = (*matcher).search(&pattern);
//         let mut c_result: Vec<MatchResult> = Vec::new();
//         todo!()
//     }
// }

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let mut matcher = Matcher::default();
        matcher.add(Item { name: "pokemon".to_string(), payload: "blah".to_string() });
        matcher.add(Item { name: "pikachu".to_string(), payload: "blah".to_string() });
        matcher.add(Item { name: "hello kitty".to_string(), payload: "blah".to_string() });
        matcher.add(Item { name: "ryuk".to_string(), payload: "blah".to_string() });

        assert_eq!(matcher.search("pik"), vec![(71, "pikachu")]);
        assert_eq!(matcher.search("hk"), vec![(47, "hello kitty")]);
        assert_eq!(matcher.search("k"),
                   vec![(23, "hello kitty"),
                        (15, "pokemon"),
                        (15, "pikachu"),
                        (15, "ryuk")]);
    }
}
