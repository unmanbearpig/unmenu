//
//  Keys.swift
//  dmenu-mac
//
//  Created by Ivan on 14.02.24.
//  Copyright © 2024 Jose Pereira. All rights reserved.
//

import Foundation
import Cocoa

class Keys {
    // converted from https://github.com/pqrs-org/cpp-hid/blob/bfee1644d54ab4c900b7585f83a356d08d123c51/include/pqrs/hid/usage.hpp#L123
    enum KeyboardOrKeypad: UInt16 {
        case keyboard_a = 0x0
        case keyboard_b = 0xb
        case keyboard_c = 0x8
        case keyboard_d = 0x2
        case keyboard_e = 0xe
        case keyboard_f = 0x3
        case keyboard_g = 0x5
        case keyboard_h = 0x4
        case keyboard_i = 0x22
        case keyboard_j = 0x26
        case keyboard_k = 0x28
        case keyboard_l = 0x25
        case keyboard_m = 0x2e
        case keyboard_n = 0x2d
        case keyboard_o = 0x1f
        case keyboard_p = 0x23
        case keyboard_q = 0xc
        case keyboard_r = 0xf
        case keyboard_s = 0x1
        case keyboard_t = 0x11
        case keyboard_u = 0x20
        case keyboard_v = 0x9
        case keyboard_w = 0xd
        case keyboard_x = 0x7
        case keyboard_y = 0x10
        case keyboard_z = 0x6
        case keyboard_1 = 0x12
        case keyboard_2 = 0x13
        case keyboard_3 = 0x14
        case keyboard_4 = 0x15
        case keyboard_5 = 0x17
        case keyboard_6 = 0x16
        case keyboard_7 = 0x1a
        case keyboard_8 = 0x1c
        case keyboard_9 = 0x19
        case keyboard_0 = 0x1d
        case keyboard_return_or_enter = 0x24
        case keyboard_escape = 0x35
        case keyboard_delete_or_backspace = 0x33
        case keyboard_tab = 0x30
        case keyboard_spacebar = 0x31
        case keyboard_hyphen = 0x1b
        case keyboard_equal_sign = 0x18
        case keyboard_open_bracket = 0x21
        case keyboard_close_bracket = 0x1e
        case keyboard_backslash = 0x2a
        // case keyboard_non_us_pound = 0x2a // non_us_pound == backslash // duplicate
        case keyboard_semicolon = 0x29
        case keyboard_quote = 0x27
        case keyboard_grave_accent_and_tilde = 0x32
        case keyboard_comma = 0x2b
        case keyboard_period = 0x2f
        case keyboard_slash = 0x2c
        case keyboard_caps_lock = 0x39
        case keyboard_f1 = 0x7a
        case keyboard_f2 = 0x78
        case keyboard_f3 = 0x63
        case keyboard_f4 = 0x76
        case keyboard_f5 = 0x60
        case keyboard_f6 = 0x61
        case keyboard_f7 = 0x62
        case keyboard_f8 = 0x64
        case keyboard_f9 = 0x65
        case keyboard_f10 = 0x6d
        case keyboard_f11 = 0x67
        case keyboard_f12 = 0x6f
        // case keyboard_print_screen = 0x69 // commented out because non-unique
        // case keyboard_scroll_lock = 0x6b // commented out because non-unique
        // case keyboard_pause = 0x71 // commented out because non-unique
        // case keyboard_insert = 0x72 // commented out because non-unique
        case keyboard_home = 0x73
        case keyboard_page_up = 0x74
        case keyboard_delete_forward = 0x75
        case keyboard_end = 0x77
        case keyboard_page_down = 0x79
        case keyboard_right_arrow = 0x7c
        case keyboard_left_arrow = 0x7b
        case keyboard_down_arrow = 0x7d
        case keyboard_up_arrow = 0x7e
        case keypad_num_lock = 0x47
        case keypad_slash = 0x4b
        case keypad_asterisk = 0x43
        case keypad_hyphen = 0x4e
        case keypad_plus = 0x45
        case keypad_enter = 0x4c
        case keypad_1 = 0x53
        case keypad_2 = 0x54
        case keypad_3 = 0x55
        case keypad_4 = 0x56
        case keypad_5 = 0x57
        case keypad_6 = 0x58
        case keypad_7 = 0x59
        case keypad_8 = 0x5b
        case keypad_9 = 0x5c
        case keypad_0 = 0x52
        case keypad_period = 0x41
        case keyboard_non_us_backslash = 0xa
        case keyboard_application = 0x6e
        case keypad_equal_sign = 0x51
        case keyboard_f13 = 0x69
        case keyboard_f14 = 0x6b
        case keyboard_f15 = 0x71
        case keyboard_f16 = 0x6a
        case keyboard_f17 = 0x40
        case keyboard_f18 = 0x4f
        case keyboard_f19 = 0x50
        case keyboard_f20 = 0x5a
        case keyboard_help = 0x72
        case keypad_comma = 0x5f
        case keyboard_international1 = 0x5e
        case keyboard_international3 = 0x5d
        case keyboard_lang1 = 0x68
        case keyboard_lang2 = 0x66
        case keyboard_left_control = 0x3b
        case keyboard_left_shift = 0x38
        case keyboard_left_alt = 0x3a
        case keyboard_left_gui = 0x37
        case keyboard_right_control = 0x3e
        case keyboard_right_shift = 0x3c
        case keyboard_right_alt = 0x3d
        case keyboard_right_gui = 0x36
        case apple_vendor_keyboard_dashboard = 0x82
        case apple_vendor_keyboard_function = 0x3f
        case apple_vendor_keyboard_launchpad = 0x83
        case apple_vendor_keyboard_expose_all = 0xa0
        // case apple_vendor_top_case_keyboard_fn = 0x3f // commented out because duplicate // apple_vendor_top_case_keyboard_fn == apple_vendor_keyboard_function
    }
    
    static let keyNameToCode: [String: UInt16] = [
        "a": 0x0,
        "b": 0xb,
        "c": 0x8,
        "d": 0x2,
        "e": 0xe,
        "f": 0x3,
        "g": 0x5,
        "h": 0x4,
        "i": 0x22,
        "j": 0x26,
        "k": 0x28,
        "l": 0x25,
        "m": 0x2e,
        "n": 0x2d,
        "o": 0x1f,
        "p": 0x23,
        "q": 0xc,
        "r": 0xf,
        "s": 0x1,
        "t": 0x11,
        "u": 0x20,
        "v": 0x9,
        "w": 0xd,
        "x": 0x7,
        "y": 0x10,
        "z": 0x6,
        "1": 0x12,
        "2": 0x13,
        "3": 0x14,
        "4": 0x15,
        "5": 0x17,
        "6": 0x16,
        "7": 0x1a,
        "8": 0x1c,
        "9": 0x19,
        "0": 0x1d,
        
        "return_or_enter": 0x24,
        "return": 0x24,
        "enter": 0x24,
        
        "escape": 0x35,
        
        "delete_or_backspace": 0x33,
        "backspace": 0x33,
        
        "tab": 0x30,
        
        "space": 0x31,
        "spacebar": 0x31,
        
        "hyphen": 0x1b,
        "equal_sign": 0x18,
        "open_bracket": 0x21,
        "close_bracket": 0x1e,
        "backslash": 0x2a,
        "non_us_pound": 0x2a, // non_us_pound == backslash
        "semicolon": 0x29,
        "quote": 0x27,
        
        "grave_accent_and_tilde": 0x32,
        "grave": 0x32,
        "tilde": 0x32,
        
        "comma": 0x2b,
        "period": 0x2f,
        "slash": 0x2c,
        "caps_lock": 0x39,
        "f1": 0x7a,
        "f2": 0x78,
        "f3": 0x63,
        "f4": 0x76,
        "f5": 0x60,
        "f6": 0x61,
        "f7": 0x62,
        "f8": 0x64,
        "f9": 0x65,
        "f10": 0x6d,
        "f11": 0x67,
        "f12": 0x6f,
        "print_screen": 0x69,
        "scroll_lock": 0x6b,
        "pause": 0x71,
        "insert": 0x72,
        "home": 0x73,
        "page_up": 0x74,
        "delete_forward": 0x75,
        "end": 0x77,
        "page_down": 0x79,
        "right_arrow": 0x7c,
        "left_arrow": 0x7b,
        "down_arrow": 0x7d,
        "up_arrow": 0x7e,
        "keypad_num_lock": 0x47,
        "keypad_slash": 0x4b,
        "keypad_asterisk": 0x43,
        "keypad_hyphen": 0x4e,
        "keypad_plus": 0x45,
        "keypad_enter": 0x4c,
        "keypad_1": 0x53,
        "keypad_2": 0x54,
        "keypad_3": 0x55,
        "keypad_4": 0x56,
        "keypad_5": 0x57,
        "keypad_6": 0x58,
        "keypad_7": 0x59,
        "keypad_8": 0x5b,
        "keypad_9": 0x5c,
        "keypad_0": 0x52,
        "keypad_period": 0x41,
        "non_us_backslash": 0xa,
        "application": 0x6e,
        "keypad_equal_sign": 0x51,
        "f13": 0x69,
        "f14": 0x6b,
        "f15": 0x71,
        "f16": 0x6a,
        "f17": 0x40,
        "f18": 0x4f,
        "f19": 0x50,
        "f20": 0x5a,
        "help": 0x72,
        "keypad_comma": 0x5f,
        "international1": 0x5e,
        "international3": 0x5d,
        "lang1": 0x68,
        "lang2": 0x66,
        "left_control": 0x3b,
        "left_shift": 0x38,
        "left_alt": 0x3a,
        "left_gui": 0x37,
        "right_control": 0x3e,
        "right_shift": 0x3c,
        "right_alt": 0x3d,
        "right_gui": 0x36,
        "apple_vendor_keyboard_dashboard": 0x82,
        "apple_vendor_keyboard_function": 0x3f,
        "apple_vendor_keyboard_launchpad": 0x83,
        "apple_vendor_keyboard_expose_all": 0xa0,
        "apple_vendor_top_case_keyboard_fn": 0x3f, // apple_vendor_top_case_keyboard_fn == apple_vendor_keyboard_function
    ]
    
    static var keyCodeToName: [UInt16: String] = {
        var dict: [UInt16: String] = [:]
        keyNameToCode.forEach { (key, value) in
            dict[value] = key
        }
        return dict
    }()
    
    static func convertToKeyCodeAndModifierFlags(shortcut: String) -> (keyCode: UInt16, modifierFlags: UInt)? {
        let components = shortcut.lowercased().components(separatedBy: "-")
        guard let key = components.last,
              let keyCode: UInt16 = self.keyNameToCode[key] else { return nil }
        
        let modifierFlag: NSEvent.ModifierFlags = components.dropLast().reduce(into: NSEvent.ModifierFlags()) { flag, component in
            switch component {
            case "cmd": flag.formUnion(.command)
                
            case "ctrl": flag.formUnion(.control)
            case "control": flag.formUnion(.control)
                
            case "alt": flag.formUnion(.option)
            case "option": flag.formUnion(.option)
                
            case "shift": flag.formUnion(.shift)
                
            case "fn": flag.formUnion(.function)
            case "function": flag.formUnion(.function)
            default: break
            }
        }
        
        return (keyCode, modifierFlag.rawValue)
    }
    
}
