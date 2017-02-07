//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  TagQueryDelegate.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation

protocol TagQueryDelegate: NSObjectProtocol {
    func didUploadItem(_ item: HistoryItem, with query: TagQuery)

    func didIdentify(_ item: HistoryItem, with query: TagQuery)

    func didDequeue(_ item: HistoryItem, with query: TagQuery)

    func didFail(_ item: HistoryItem, with query: TagQuery)
}