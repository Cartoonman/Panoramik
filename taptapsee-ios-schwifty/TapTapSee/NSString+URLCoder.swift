//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  NSString+URLCoder.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
extension NSString {
    func urlEncode() -> String {
        return (CFURLCreateStringByAddingPercentEscapes(nil, (self as? CFString), nil, ("!*'();:@&=+$,/?%#[]" as? CFString), kCFStringEncodingUTF8) as? String)!
    }

    func urlDecode() -> String {
        return (CFURLCreateStringByReplacingPercentEscapesUsingEncoding(nil, (self as? CFString), CFSTR(""), kCFStringEncodingUTF8) as? String)!
    }
}