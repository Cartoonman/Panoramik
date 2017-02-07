//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  HistoryItem.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation

let SER_KEY_UNIQUE_NAME = "uniqueName"
let SER_KEY_IMAGE_FILE = "imageFile"
let SER_KEY_THUMB_FILE = "thumbFile"
let SER_KEY_TITLE = "title"
let SER_KEY_STATUS = "status"
let SER_KEY_PLACEMARK = "placemark"
let SER_KEY_IS_FOUND = "isFound"
let SER_KEY_IS_FAILED = "isFailed"
class HistoryItem: NSObject {
    var uniqueName: String = ""
    var imageFile: String = ""
    var thumbFile: String = ""
    var queryNumber: Int = 0
    var title: String = ""
    var status: String = ""
    var placemark: Placemark!
    var isFound: Bool = false
    var isFailed: Bool = false
    var cloudSightQuery: CloudSightQuery!
    var tagQuery: TagQuery!

    func thumbSizeInPixels() -> CGSize {
        var screenScale: CGFloat = 1.0
        // Retina display.
        if UIScreen.main.responds(to: Selector("displayLinkWithTarget:selector:")) {
            screenScale = UIScreen.main.scale()
        }
        return CGSize(width: CGFloat(THUMB_WIDTH * screenScale), height: CGFloat(THUMB_HEIGHT * screenScale))
    }

    func imageName() -> String {
        return "\(self.uniqueName()).jpg"
    }

    func thumbName() -> String {
        return "\(self.uniqueName()).jpg"
    }

    func shortDescription() -> String {
        if self.isFound() {
            return self.title
        }
        return self.status
    }

    override func image() -> UIImage {
        return HistoryItemStore.image(forFilename: self.imageFile())
    }

    func thumbnailImage() -> UIImage {
        return HistoryItemStore.image(forFilename: self.thumbFile())
    }

    func shareActivityItems() -> [Any] {
        var items = [Any]() /* capacity: 0 */
        var shareActivityProvider = ShareHistoryItemActivityProvider(self)
        items.append(shareActivityProvider)
        if self.image() != nil {
            items.append(self.image())
        }
        return items
    }

    func hasLocation() -> Bool {
        return (self.placemark != nil)
    }

    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        
        self.uniqueName = (dict[SER_KEY_UNIQUE_NAME] as? String)
        self.imageFile = (dict[SER_KEY_IMAGE_FILE] as? String)
        self.thumbFile = (dict[SER_KEY_THUMB_FILE] as? String)
        self.title = (dict[SER_KEY_TITLE] as? String)
        self.status = (dict[SER_KEY_STATUS] as? String)
        self.isFound = (dict[SER_KEY_IS_FOUND] as? String) ? true : false
        self.isFailed = (dict[SER_KEY_IS_FAILED] as? String) ? true : false
        var placemarkDict: [AnyHashable: Any]? = (dict[SER_KEY_PLACEMARK] as? String)
        self.placemark = placemarkDict
    
    }

    func encode(withDictionary dict: [AnyHashable: Any]) {
        if self.uniqueName {
            dict[SER_KEY_UNIQUE_NAME] = self.uniqueName
        }
        if self.imageFile {
            dict[SER_KEY_IMAGE_FILE] = self.imageFile
        }
        if self.thumbFile {
            dict[SER_KEY_THUMB_FILE] = self.thumbFile
        }
        if self.title {
            dict[SER_KEY_TITLE] = self.title
        }
        if self.status {
            dict[SER_KEY_STATUS] = self.status
        }
        if self.isFound {
            dict[SER_KEY_IS_FOUND] = Int(self.isFound)
        }
        if self.isFailed {
            dict[SER_KEY_IS_FAILED] = Int(self.isFailed)
        }
        if self.placemark {
            var placemarkDict = [AnyHashable: Any]()
            self.placemark.encode(withDictionary: placemarkDict)
            dict[SER_KEY_PLACEMARK] = placemarkDict
        }
    }


    override init() {
        super.init()
        
        self.uniqueName = UIImage.uniqueName()
    
    }

    override func description() -> String {
        return "id:'\(self.uniqueName)', status:'\(self.status)', image:'\(self.imageFile)', thumb:'\(self.thumbFile)', placemark: '\(self.placemark)'"
    }
// MARK: Serialization
}