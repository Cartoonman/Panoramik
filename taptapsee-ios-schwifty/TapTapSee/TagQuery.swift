//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  TagQuery.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import CloudSight
let TAG_QUERY_WAIT = 0
let TAG_QUERY_SEND = 1
let TAG_QUERY_IDENTIFY = 2
let TAG_QUERY_DONE = 3
let TAG_QUERY_FAIL = 4

class TagQuery: NSObject, CloudSightQueryDelegate {
    var cloudSightQuery: CloudSightQuery!

    weak var delegate: TagQueryDelegate?
    var historyItem: HistoryItem!
    var image: UIImage!
    var location = CGPoint.zero
    var status: Int = 0

    override init(delegate: Any, with image: UIImage, atLocation location: CGPoint, with historyItem: HistoryItem) {
        super.init()
        
        self.delegate = delegate
        self.image = image
        self.location = location
        self.historyItem = historyItem
    
    }

    override func start() {
        var imageData: Data?
        // Change to a smaller image if we're using WWAN instead of WiFi
        if TMReachability().isReachableViaWiFi() {
            imageData = self.image.asJPEG(with: WIFI_QUALITY)
        }
        else {
            imageData = self.image.asJPEG(with: WWAN_QUALITY)
        }
        // Start CloudSight
        cloudSightQuery = CloudSightQuery(image: imageData, atLocation: self.location, withDelegate: self, atPlacemark: self.historyItem.placemark.toCLLocation(), withDeviceId: "")
        cloudSightQuery.start()
        self.historyItem.cloudSightQuery = cloudSightQuery
    }


    deinit {
        DDLogDebug("dealloc")
    }

    override func description() -> String {
        return "status: \(self.status), historyItem: \(self.historyItem)"
    }

    override func cancel() {
        cloudSightQuery.stop()
    }

    func didFail(withMessage error: String) {
        self.historyItem.status = error
        self.historyItem.isFailed = true
        self.delegate.didFail(self.historyItem, with: self)
    }
// MARK: CloudSightQuery delegate implementation

    func cloudSightQueryDidFinishIdentifying(_ query: CloudSightQuery) {
        DDLogDebug("cloudSightQueryDidFinishIdentifying: %@", query)
        if self.historyItem != nil && !self.historyItem.isFound {
            self.historyItem.title = self.historyItem.cloudSightQuery.name
            self.historyItem.isFound = true
            self.delegate.didIdentify(self.historyItem, with: self)
        }
    }

    func cloudSightQueryDidFinishUploading(_ query: CloudSightQuery) {
        DDLogDebug("cloudSightQueryDidFinishUploading: %@", query)
        if self.historyItem != nil && !self.historyItem.isFound {
            self.historyItem.status = "Identifying..."
            self.delegate.didUploadItem(self.historyItem, with: self)
        }
    }

    func cloudSightQueryDidFail(_ query: CloudSightQuery, withError error: Error?) {
        DDLogDebug("cloudSightQueryDidFail: %@", error)
        self.didFail(withMessage: error?.localizedDescription)
    }

    func cloudSightQueryDidUpdateTag(_ query: CloudSightQuery) {
        DDLogDebug("cloudSightDidUpdateTag: %@", query)
    }
}
import CloudSight
let WWAN_QUALITY = 0.4
let WIFI_QUALITY = 0.7