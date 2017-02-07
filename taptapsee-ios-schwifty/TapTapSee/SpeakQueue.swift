//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  SpeakQueue.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
class SpeakQueue: NSObject {
    var items = [Any]()
    var busy: Bool = false

    class func shared() -> SpeakQueue {
        var sharedQueue: SpeakQueue? = nil
        if sharedQueue == nil {
            // Skip over alloc override below
            sharedQueue = super.alloc(withZone: nil)()
        }
        return sharedQueue!
    }

    func speak(_ message: String) {
        // Queue for speaking if we've got the notifications available to us
        if kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1 {
            busy = true
            items.append(message)
            if items.count == 1 {
                self.dequeueAndSpeak()
            }
            // Otherwise just post the notification straight to VoiceOver
        }
        else if kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iPhoneOS_3_2 {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message)
        }

    }

    func isBusy() -> Bool {
        return busy
    }


    class func alloc(with zone: NSZone) -> Any {
        return self.shared()
    }

    override init() {
        super.init()
        
        items = [Any]() /* capacity: 0 */
        busy = false
        if kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishAnnouncement), name: UIAccessibilityAnnouncementDidFinishNotification, object: nil)
        }
    
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func dequeueAndSpeak() {
        // Sanity check an empty queue
        if items.count == 0 {
            return
        }
            // Dequeue the message
        var message: String? = (items[0] as? String)
        items.remove(at: 0)
            // Speak the message
        var delay = DispatchTime.now() + Double(0.1 * Double(NSEC_PER_SEC))
        var queue = DispatchQueue.global(qos: .default)
        queue.asyncAfter(deadline: delay / Double(NSEC_PER_SEC), execute: {() -> Void in
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message)
        })
    }

    func didFinishAnnouncement(_ dict: Notification) {
        var valueSpoken: String? = (dict.userInfo?[UIAccessibilityAnnouncementKeyStringValue] as? String)
        var wasSuccessful: String? = (dict.userInfo?[UIAccessibilityAnnouncementKeyWasSuccessful] as? String)
        print("didFinishAnnouncement: \(wasSuccessful ? "Yes" : "No"), \(valueSpoken)")
        // Since we just finished one (doesn't matter if it was success or not) dequeue and run another
        self.dequeueAndSpeak()
        // Only mark non-busy when we're done speaking the last one in the queue
        if items.count == 0 {
            busy = false
        }
    }
}