//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  NSString+UUID.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
extension NSString {
    class func uuid() -> String {
        var uuidString: String? = nil
        var uuid: CFUUIDRef = CFUUIDCreate(nil)
        if uuid != nil {
            uuidString = (CFUUIDCreateString(nil, uuid) as? String)
        }
        return uuidString!
    }
}