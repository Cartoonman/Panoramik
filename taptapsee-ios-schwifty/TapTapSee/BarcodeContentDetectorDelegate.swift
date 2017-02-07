//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  BarcodeContentDetectorDelegate.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
protocol BarcodeContentDetectorDelegate: NSObjectProtocol {
    func barcodeContentDetector(_ sender: Any, didIdentifyWith item: String)
}