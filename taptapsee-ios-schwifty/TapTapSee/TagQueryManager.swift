//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  TagQueryManager.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
class TagQueryManager: NSObject, TagQueryDelegate {
    var queries = [Any]()
    var periodicReassessTimer: Timer!
    var busyCount: Int = 0

    weak var delegate: TagQueryDelegate?

    class func shared() -> TagQueryManager {
        var sharedManager: TagQueryManager? = nil
        if sharedManager == nil {
            // Skip over alloc override below
            sharedManager = super.alloc(withZone: nil)()
        }
        return sharedManager!
    }

    func query(with image: UIImage, withFocus location: CGPoint, with historyItem: HistoryItem) -> TagQuery {
        var query = TagQuery(delegate: self, with: image, atLocation: location, with: historyItem)
        query.status = TAG_QUERY_WAIT
        queries.append(query)
        self.startPeriodicReassessTimer()
        return query
    }

    override func reset() {
        queries.removeAll()
    }

    func busyCount() -> Int {
        return busyCount
    }

    func restart(_ item: HistoryItem) {
        var query: TagQuery? = self.tagQuery(for: item)
        query?.status = TAG_QUERY_WAIT
        self.startPeriodicReassessTimer()
    }

    func tagQuery(for item: HistoryItem) -> TagQuery {
        for query: TagQuery in queries {
            if query?.historyItem() == item {
                return query!
            }
        }
        return nil
    }


    class func alloc(with zone: NSZone) -> Any {
        return self.shared()
    }

    override init() {
        super.init()
        
        queries = [Any]() /* capacity: 0 */
    
    }

    deinit {
        print("TagQueryManager got dealloc'ed")
        self.stopPeriodicReassessTimer()
    }

    func startPeriodicReassessTimer() {
        // Check if we're already running
        if periodicReassessTimer != nil {
            return
        }
        periodicReassessTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.reassessQueryQueue), userInfo: nil, repeats: true)
    }

    func stopPeriodicReassessTimer() {
        // Check if we're already stopped
        if periodicReassessTimer == nil {
            return
        }
        periodicReassessTimer.invalidate()
        periodicReassessTimer = nil
    }

    func reassessQueryQueue() {
        var waiting: Int = 0
        var sending: Int = 0
        var identifying: Int = 0
        var done: Int = 0
        var failed: Int = 0
        for query: TagQuery in queries {
            if query?.status == TAG_QUERY_WAIT {
                waiting += 1
            }
            if query?.status == TAG_QUERY_SEND {
                sending += 1
            }
            if query?.status == TAG_QUERY_IDENTIFY {
                identifying += 1
            }
            if query?.status == TAG_QUERY_DONE {
                done += 1
            }
            if query?.status == TAG_QUERY_FAIL {
                failed += 1
            }
        }
        busyCount = waiting + sending + identifying
        // Check to see if we're idle and stop the periodic timer
        if busyCount < 1 {
            self.stopPeriodicReassessTimer()
        }
            // Dequeue and start as long as the queue counts make sense
        var reachability = TMReachability()
        var max_simultaneous_send: Int = reachability.isReachableViaWiFi() ? MAX_SIMULTANEOUS_SEND_ON_WIFI : MAX_SIMULTANEOUS_SEND_ON_WWAN
        print("TagQueryManager (max send \(max_simultaneous_send)): WAIT: \(waiting), SEND: \(sending), IDENTIFY: \(identifying), DONE: \(done), FAIL: \(failed)")
        if waiting > 0 && sending < max_simultaneous_send {
            // Find the first waiting query
            for query: TagQuery in queries {
                if query?.status == TAG_QUERY_WAIT {
                    // Mark this one as sending (and send)
                    query?.status = TAG_QUERY_SEND
                    query?.start()
                    // Notify upstream
                    self.didDequeue(query?.historyItem(), with: query)
                    return
                }
            }
        }
    }
// MARK: TagQuery implementation

    func didUploadItem(_ item: HistoryItem, with query: TagQuery) {
        query.status = TAG_QUERY_IDENTIFY
        if self.delegate {
            DispatchQueue.main.async(execute: {() -> Void in
                self.delegate.didUploadItem(item, with: query)
            })
        }
        self.reassessQueryQueue()
    }

    func didIdentify(_ item: HistoryItem, with query: TagQuery) {
        query.status = TAG_QUERY_DONE
        if self.delegate {
            DispatchQueue.main.async(execute: {() -> Void in
                self.delegate.didIdentify(item, with: query)
            })
        }
    }

    func didDequeue(_ item: HistoryItem, with query: TagQuery) {
        item.status = "Sending image..."
        if self.delegate {
            DispatchQueue.main.async(execute: {() -> Void in
                self.delegate.didDequeue(item, with: query)
            })
        }
    }

    func didFail(_ item: HistoryItem, with query: TagQuery) {
        query.status = TAG_QUERY_FAIL
        if self.delegate {
            DispatchQueue.main.async(execute: {() -> Void in
                self.delegate.didFail(item, with: query)
            })
        }
    }
}
let MAX_SIMULTANEOUS_SEND_ON_WWAN = 1
let MAX_SIMULTANEOUS_SEND_ON_WIFI = 3