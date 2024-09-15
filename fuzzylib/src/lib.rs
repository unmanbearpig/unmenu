use std::path::{Path, PathBuf};
use std::fs::{DirEntry, Metadata, FileType};
use std::os::unix::fs::PermissionsExt;
use serde_derive::{Serialize, Deserialize};

use fuzzy_matcher::skim::SkimMatcherV2;
use fuzzy_matcher::FuzzyMatcher;

use std::ffi::{CString, CStr, c_char};
use std::fs::File;
use std::io::{BufReader, Read, Write};
use toml;

use regex;
extern crate libc;
use std::ptr;

// for checking if something is allocated
// extern "C" {
//     fn malloc_size(ptr: *const c_void) -> size_t;
// }

// fn get_allocation_size(ptr: *const c_void) -> usize {
//     unsafe { malloc_size(ptr) as usize }
// }

use objc_foundation::{INSString, NSString, NSObject};

use objc::runtime::Object;
use objc::{class, msg_send, sel, sel_impl};

fn open_application(app_path: &str) -> Result<(), Error> {
    let nsautorelease_pool = class!(NSAutoreleasePool);
    let pool: *mut Object = unsafe { msg_send![nsautorelease_pool, new] };

    let workspace: *mut Object = unsafe {
        msg_send![class!(NSWorkspace), performSelector: sel!(sharedWorkspace)]
    };

    // println!("creating a path");
    let path: *mut Object = unsafe {
        let nsstr = NSString::from_str(app_path);
        msg_send![class!(NSURL), fileURLWithPath: nsstr]
    };

    // println!("creating an open conf");
    // let conf = NSWorkspace.Opennonfiguration.init()
    let conf: NSObject = unsafe {
        // msg_send![class!(NSWorkspace.OpenConfiguration), init]
        // let configuration: *mut Object = msg_send![class!(NSWorkspace), OpenConfiguration];
        let configuration = objc::runtime::Class::get("NSWorkspaceOpenConfiguration")
            .expect("couldn't get openconf class");
        msg_send![configuration, new]
    };

    // println!("launching...");
    unsafe {
        let _: () = msg_send![
            workspace,
            launchApplicationAtURL: path
                options: 0
                configuration: conf //ptr::null_mut::<usize>()
                error: ptr::null_mut::<usize>()
        ];
    }

    // println!("pool release");
    unsafe {
        let _: () = msg_send![pool, release];
    }

    // println!("end");

    Ok(())
}







type Error = Box<dyn std::error::Error>;

// See unmenu Config.swift file
#[derive(Debug, Clone, Serialize, Deserialize)]
struct Hotkey {
    qwerty_hotkey: Option<String>,
    key_code: Option<u16>,
    modifier_flags: Option<u16>,
}

impl Default for Hotkey {
    fn default() -> Hotkey {
        Hotkey {
            qwerty_hotkey: Some("ctrl-cmd-x".to_string()),
            key_code: None,
            modifier_flags: None,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Config {
    find_apps: bool,
    find_executables: bool,
    dirs: Vec<PathBuf>,
    ignore_names: Vec<String>,
    ignore_patterns: Vec<String>,
}

impl Default for Config {
    fn default() -> Config {
        let ignore_patterns =
            vec!["^Install.*", ".*Installer\\.app$", "\\.bundle$"]
            .into_iter().map(|s| s.to_string())
            .collect();

        let ignore_names = vec![
            "unmenu.app",
            ".Karabiner-VirtualHIDDevice-Manager.app", "Install Command Line Developer Tools.app",
            "Install in Progress.app", "Migration Assistant.app", "TextInputMenuAgent.app",
            "TextInputSwitcher.app", "AOSUIPrefPaneLauncher.app",
            "Automator Application Stub.app", "NetAuthAgent.app", "Captive Network Assistant.app",
            "screencaptureui.app", "ScreenSaverEngine.app", "SystemUIServer.app",
            "UIKitSystem.app", "NowPlayingTouchUI.app", "WindowManager.app",
            "APFSUserAgent", "AVB Audio Configuration.app", "AddPrinter.app",
            "AddressBookUrlForwarder.app", "AirPlayUIAgent.app", "AirPort Base Station Agent.app",
            "AppleScript Utility.app", "Automator Application Stub.app", "Automator Installer.app",
            "BluetoothSetupAssistant.app", "BluetoothUIServer.app",
            "BluetoothUIService.app", "CSUserAgent", "CalendarFileHandler.app",
            "Captive Network Assistant.app", "Certificate Assistant.app", "CloudSettingsSyncAgent",
            "ControlCenter.app", "ControlStrip.app", "CoreLocationAgent.app", "CoreServicesUIAgent.app",
            "Coverage Details.app", "CrashReporterSupportHelper", "DMProxy",
            "Database Events.app", "DefaultBackground.jpg", "DefaultDesktop.heic",
            "Diagnostics Reporter.app", "DiscHelper.app", "DiskImageMounter.app", "Dock.app",
            "Dwell Control.app", "Erase Assistant.app", "EscrowSecurityAlert.app",
            "ExpansionSlotNotification", "FolderActionsDispatcher.app", "HelpViewer.app",
            "IOUIAgent.app", "Image Events.app", "Install Command Line Developer Tools.app",
            "Install in Progress.app", "Installer Progress.app", "Installer.app",
            "JavaLauncher.app", "KeyboardAccessAgent.app", "KeyboardSetupAssistant.app",
            "Keychain Circle Notification.app", "Language Chooser.app", "MTLReplayer.app",
            "ManagedClient.app", "MapsSuggestionsTransportModePrediction.mlmodelc",
            "MemorySlotNotification", "Menu Extras", "NetAuthAgent.app",
            "NowPlayingTouchUI.app", "OBEXAgent.app", "ODSAgent.app", "OSDUIHelper.app",
            "PIPAgent.app", "PodcastsAuthAgent.app", "PowerChime.app", "Pro Display Calibrator.app",
            "Problem Reporter.app", "ProfileHelper.app", "RapportUIAgent.app",
            "RegisterPluginIMApp.app", "RemoteManagement", "RemotePairTool", "ReportCrash",
            "Resources", "RestoreVersion.plist", "Rosetta 2 Updater.app",
            "ScopedBookmarkAgent", "ScreenSaverEngine.app", "Script Menu.app",
            "ScriptMonitor.app", "SecurityAgentPlugins", "ServicesUIAgent",
            "Setup Assistant.app", "SetupAssistantPlugins", "ShortcutDroplet.app", "Shortcuts Events.app",
            "SpacesTouchBarAgent.app", "StageManagerEducation.app", "SubmitDiagInfo",
            "SystemFolderLocalizations", "SystemUIServer.app", "SystemVersion.plist",
            "SystemVersionCompat.plist", "TextInputMenuAgent.app", "TextInputSwitcher.app",
            "ThermalTrap.app", "Tips.app", "UAUPlugins", "UIKitSystem.app",
            "UniversalAccessControl.app", "UniversalControl.app", "UnmountAssistantAgent.app",
            "UserAccountUpdater", "UserNotificationCenter.app", "UserPictureSyncAgent",
            "VoiceOver.app", "WatchFaceAlert.app", "WiFiAgent.app",
            "WidgetKit Simulator.app", "WindowManager.app", "Xcode Previews.app",
            "appleeventsd", "boot.efi", "cacheTimeZones", "cloudpaird", "com.apple.NSServicesRestrictions.plist",
            "coreservicesd", "destinationd", "diagnostics_agent", "iCloud+.app",
            "iCloud.app", "iOSSystemVersion.plist", "iTunesStoreURLPatterns.plist",
            "iconservicesagent", "iconservicesd", "ionodecache", "launchservicesd",
            "lockoutagent", "logind", "loginwindow.app", "mapspushd", "navd",
            "osanalyticshelper", "pbs", "rc.trampoline", "rcd.app", "screencaptureui.app",
            "sessionlogoutd", "sharedfilelistd", "talagent", "uncd", "NotificationCenter.app"];
        let ignore_names = ignore_names.into_iter().map(|s| s.to_string())
            .collect();

        let dirs = vec![
            "/System/Applications/".into(),
            "/Applications/".into(),
            "/System/Applications/Utilities/".into(),
            "/System/Library/CoreServices/".into(),
        ];
        Config {
            find_apps: true,
            find_executables: true,
            dirs,
            ignore_names,
            ignore_patterns,
        }
    }
}

impl Config {
    fn get_file_path() -> Result<PathBuf, Error> {
        let home_dir = std::env::var("HOME")
            .map_err(|_| "Failed to get home directory")?;
        let path = format!("{}/.config/unmenu/config.toml", home_dir);
        let path_path = Path::new(&path);
        return Ok(path_path.to_path_buf())
    }

    fn read_file() -> Result<Config, Error> {
        let path = Config::get_file_path()?;
        eprintln!("fuzzylib: config path: {path:?}");
        if !path.exists() {
            eprintln!("fuzzylib: config file doesn't exist");
            return Ok(Config::default())
        }

        let file = File::open(&path)
            .map_err(|_| format!("Failed to open file: {:?}", path))?;
        let mut reader = BufReader::new(file);
        let mut contents = String::new();
        reader.read_to_string(&mut contents)
            .map_err(|_| format!("Failed to read file: {:?}", path))?;

        let config: Config = toml::from_str(&contents)
            .map_err(|e| format!("Failed to parse TOML: {}", e))?;

        eprintln!("fuzzylib: loaded config file");

        Ok(config)
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
enum AppType {
    MacApp = 0,
    Executable = 1,
}

impl std::fmt::Display for AppType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> Result<(), std::fmt::Error> { 
        match self {
            AppType::MacApp => write!(f, "A"),
            AppType::Executable => write!(f, "X"),
        }
    }
}

#[derive(Debug, Clone, Eq, PartialEq)]
pub struct Item {
    name: String,
    cname: CString,
    path: PathBuf,
    app_type: AppType,
}

impl std::fmt::Display for Item {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> Result<(), std::fmt::Error> { 
        let name = &self.name;
        let ty = self.app_type;
        let mut path = self.path.as_os_str().to_str();
        if path.is_none() {
            path = Some("<Error>")
        }
        let path = path.unwrap();

        write!(f, "{ty}: {name} path: {path}")
    }
}

impl Item {
    pub fn open(&self) -> Result<(), Error> {
        match self.app_type {
            AppType::MacApp => {
                if let Err(err) = open_application(self.path.as_os_str().to_str().expect("Couldn't make str from app path")) {
                    eprintln!("Error opening app {}: {err:?}", self.name);
                }
            },
            AppType::Executable => {
                std::process::Command::new(&self.path)
                    .stdout(std::process::Stdio::null())
                    .stderr(std::process::Stdio::null())
                    .spawn()?;
            },
        }
        Ok(())
    }
}

#[derive(Default)]
pub struct Matcher {
    config: Config,
    matcher: SkimMatcherV2,
    pub items: Vec<Item>,
    ignore_patterns: Vec<regex::Regex>,
}

fn is_executable(file_type: &FileType, metadata: &Metadata) -> bool {
    metadata.permissions().mode() & 0o111 != 0 && file_type.is_file()
}

fn is_mac_app(file_path: &Path) -> bool {
    if let Some(file_name) = file_path.file_name() {
        if let Some(name) = file_name.to_str() {
            if name.ends_with(".app") {
                let info_plist_path = file_path.join("Contents");
                if info_plist_path.exists() {
                    return true;
                }
            }
        }
    }

    false
}

fn get_executable_name(entry: &DirEntry) -> String {
    let mut name = entry.path()
        .file_name().expect("couldn't get file name")
        .to_str().expect("couldn't get str for filename")
        .to_string();

    if name.ends_with(".app") {
        let new_length = name.len() - 4; // Remove the length of ".app"
        name.truncate(new_length);
    }
    name
}

fn resolve_tilde(path: &Path) -> PathBuf {
    if path.starts_with("~") {
        let home_dir = std::env::home_dir().expect("Failed to get home directory");
        home_dir.join(path.strip_prefix("~").unwrap())
    } else {
        path.to_path_buf()
    }
}

impl Matcher {
    fn load_ignore_patterns(&mut self) -> Result<(), Error> {
        self.ignore_patterns.clear();
        for pattern in self.config.ignore_patterns.iter() {
            self.ignore_patterns.push(regex::Regex::new(pattern)?);
        }
        Ok(())
    }

    pub fn new() -> Result<Matcher, Error> {
        let mut config = Config::read_file();
        if let Err(err) = config {
            println!("Error loading config: {err:?}");
            config = Ok(Config::default());
        }
        let config = config.unwrap();

        let mut matcher = Matcher {
            config,
            matcher: SkimMatcherV2::default(),
            items: Vec::new(),
            ignore_patterns: Vec::new(),
        };
        matcher.load_ignore_patterns()?;

        Ok(matcher)
    }

    fn entry_filtered_out(&self, dir_entry: &DirEntry) -> bool {
        let file_name = dir_entry.file_name();
        let file_name = file_name.to_str();

        let file_path = dir_entry.path();
        let file_path = file_path.to_str();
        if file_path.is_none() { return true };
        let file_path = file_path.unwrap();

        if file_name.is_none() { return true };
        let file_name = file_name.unwrap();

        if self.config.ignore_names.iter().any(|n| file_name == n || file_path == n) {
            return true;
        }

        if self.ignore_patterns.iter().any(|rx| rx.is_match(file_name) || rx.is_match(file_path)) {
            return true
        }
        false
    }

    fn scan_dir(&mut self, orig_dir: &Path) {
        eprintln!("reading directory {orig_dir:?}");
        let dir = &orig_dir.canonicalize().expect("Couldn't canonicalize dir path {orig_dir:?}");

        let dir_items = std::fs::read_dir(dir);
        if let Err(err) = dir_items {
            eprintln!("Could not read dir {dir:?}: {err:?}");
            return;
        }
        let dir_items = dir_items.unwrap();

        for entry in dir_items {
            if let Err(err) = entry {
                panic!("dir entry error: {err:?}")
            }
            let entry = entry.unwrap();


            let path = entry.path().canonicalize();
            if let Err(err) = path {
                eprintln!("Could not resolve symlink for {entry:?}: {err:?}");
                continue;
            }
            let path = path.unwrap();

            let metadata = path.metadata();
            if let Err(err) = metadata {
                eprintln!("Could not get metadata for {path:?}: {err:?}");
                continue;
            }
            let metadata = metadata.unwrap();

            let file_type = metadata.file_type();

            if is_executable(&file_type, &metadata) {
                if self.config.find_executables && !self.entry_filtered_out(&entry) {
                    let name = get_executable_name(&entry);
                    self.items.push(Item {
                        name: name.clone(),
                        cname: CString::new(name).unwrap(),
                        path: path,
                        app_type: AppType::Executable,
                    });
                }
            } else if is_mac_app(&path) {
                if self.config.find_apps && !self.entry_filtered_out(&entry) {
                    let name = get_executable_name(&entry);
                    self.items.push(Item {
                        name: name.clone(),
                        cname: CString::new(name).unwrap(),
                        path: path,
                        app_type: AppType::MacApp,
                    });
                }
            }
        }
    }

    fn create_config_if_missing(&self) -> Result<(), Error> {
        let toml_content = toml::to_string(&self.config)?;

        // Specify the path to the file
        let path = Config::get_file_path()?;

        // Create the parent directory if it doesn't exist
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }

        // Open the file with write mode (if it exists) or create mode (if it doesn't exist)
        let file = std::fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .open(path);

        match file {
            Ok(mut file) => {
                // Write the TOML content to the file
                file.write_all(toml_content.as_bytes())?;
            }
            Err(ref e) if e.kind() == std::io::ErrorKind::AlreadyExists => {
                // File already exists, do nothing
                return Ok(());
            }
            Err(e) => {
                return Err(e.into());
            }
        }

        Ok(())
    }

    fn reload_config(&mut self) -> Result<(), Error> {
        println!("-> reload_config");
        println!("   prev config: {:?}", self.config);
        self.config = Config::read_file()?;
        self.load_ignore_patterns()?;
        println!("config: {:?}", self.config);
        Ok(())
    }

    /// scans all dirs in config
    pub fn rescan(&mut self) {
        println!("-> rescan");
        self.create_config_if_missing().expect("error while creating config file");

        if let Err(err) = self.reload_config() {
            println!("Error loading config: {err:?}");
        }

        self.items.clear();
        let config = self.config.clone();
        for dir in config.dirs {
            self.scan_dir(&resolve_tilde(&dir));
        }
    }

    pub fn search(&self, pattern: &str) -> Vec<&Item> {
        println!("-> search \"{pattern}\"");
        if pattern == "" {
            return Vec::new();
        }

        let mut result: Vec<(i64, &Item)> = Vec::new();
        for item in &self.items {
            if let Some(score) = self.matcher.fuzzy_match(&item.name, pattern) {
                result.push((score, item))
            }
        }
        result.sort_by_key(|(k, _)| -*k);
        for (rank, item) in result.iter() {
            println!("     {rank} {item}");
        }
        let result = result.into_iter().map(|(_,v)| v).collect();

        println!("");
        result
    }
}


// C API

#[no_mangle]
pub extern "C" fn matcher_new() -> *mut Matcher {
    let matcher = Matcher::new();
    if matcher.is_err() {
        return 0 as *mut Matcher
    }
    let matcher = matcher.unwrap();
    Box::into_raw(Box::new(matcher))
}

#[no_mangle]
pub extern "C" fn matcher_rescan(matcher: *mut Matcher) {
    let matcher = unsafe { &mut *(matcher as *mut Matcher) };
    matcher.rescan();
}

// For debugging
// fn print_mem_at_addr(addr: usize) {
//     if addr == 0 {
//         println!("print_mem_at_addr called on 0");
//         return;
//     }
//     unsafe {
//         println!("bytes at {:0x}:", addr);
//         // Access the memory bytes
//         let byte_slice: &[u8] = std::slice::from_raw_parts(addr as *const u8, 128); // Replace <number_of_bytes> with the desired size
// 
//         // Print the byte values
//         for (ii, byte) in byte_slice.iter().enumerate() {
//             if ii % 8 == 0 {
//                 print!("\n");
//             }
//             print!("{:02X} ", byte);
//         }
//         print!("\n");
//     }
// }

#[no_mangle]
pub extern "C" fn matcher_search(matcher: *const Matcher, pattern: *const c_char) -> *mut SearchResults {
    // println!(" ========================================================");
    // println!(" ========== -> matcher_search ===========================");
    // println!(" ========================================================");

    let matcher = unsafe { &*(matcher as *const Matcher) };
    let pattern = unsafe { CStr::from_ptr(pattern).to_string_lossy().into_owned() };
    let items = matcher.search(&pattern);

    // for (ii, item) in items.iter().enumerate() {
    //     println!("item {ii} name = {}", item.name);
    // }

    let num_items = items.len() as u64;

    let item_pointers: Vec<*const Item> = items.iter().map(|item| (*item) as *const Item).collect();

    // println!("rust: matcher_search num_items = {num_items}");

    // let mut prev_ptr = 0usize;
    // for (ii, ptr) in item_pointers.iter().enumerate() {
    //     let ptr_usize = (*ptr as *const Item) as usize;
    //     // println!("ptr {ii} = {ptr_usize:0x} diff = {:0x}", ptr_usize - prev_ptr);
    //     // println!("ptr {ii} = {ptr_usize:0x}");
    //     prev_ptr = ptr_usize;
    // }


    let pointer_to_item_pointers = if item_pointers.is_empty() {
        0 as *const *const Item
    } else {
        item_pointers.as_ptr()
    };

    // Don't dealloc it now
    std::mem::forget(item_pointers);
    std::mem::forget(items);

    let results = Box::new(SearchResults {
        num_items,
        items: pointer_to_item_pointers,
    });


    let result_ptr = Box::into_raw(results);

    // let items_ptr = unsafe { (*result_ptr).items as usize };
    // println!("items_ptr = {:0x}", items_ptr);

    // println!("---------------------------------------------------------");
    // println!("------------ returning from rust search -----------------");
    // println!("------------ {:0x} -----------------------", result_ptr as usize);
    // println!("---------------------------------------------------------");

    result_ptr
}


#[repr(C)]
pub struct SearchResults {
    num_items: u64,
    items: *const *const Item,
}

#[no_mangle]
pub extern "C" fn search_results_free(results: *mut SearchResults) {
    if !results.is_null() {
        let results = unsafe { Box::from_raw(results) };
        if !results.items.is_null() {
            let num_items = results.num_items;
            let items = results.items;
            if num_items != 0 {
                let item_pointers = unsafe {
                    Vec::from_raw_parts(items as *mut *const Item,
                                        results.num_items as usize,
                                        results.num_items as usize) };
                drop(item_pointers);
            }
            drop(results);
        }
    }

    // let alloc_size = get_allocation_size(results as *const c_void);
    // println!("after alloc size of {:0x} - result_ptr = {alloc_size}", results as usize);
}

#[no_mangle]
pub extern "C" fn item_open(item: *const Item) {
    if item.is_null() { return; }

    let item_ref = unsafe { &*item };
    let _ = item_ref.open();
}

#[no_mangle]
pub extern "C" fn get_item_name(item: *const Item) -> *const std::ffi::c_char {
    // println!("-> get_item_name item ptr = {:0x}", item as usize);
    if item.is_null() {
        return std::ptr::null_mut();
    }

    // let cname_ptr = unsafe { std::ptr::addr_of!((*item).cname) } as usize;
    // println!("   get_item_name cname_ptr = {cname_ptr:0x}");

    let ret = unsafe { (*item).cname.as_c_str().as_ptr() };

    // let item_ref = unsafe { &*item };

    // let ret = item_ref.cname.as_c_str().as_ptr();
    // println!("   get_item_name ret = {:0x}", ret as usize);
    ret

    // println!("item name = {}", item_ref.name);

    // // Convert the name to a C string
    // // let name_cstring = std::ffi::CString::new(item_ref.name.clone()).unwrap();
    // // let name_cstring = std::ffi::CString::new(item_ref.name).unwrap();

    // // Transfer ownership to C
    // name_cstring.into_raw()
}

