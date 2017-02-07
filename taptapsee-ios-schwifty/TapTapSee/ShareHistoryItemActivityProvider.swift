//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  ShareHistoryItemActivityProvider.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit
class ShareHistoryItemActivityProvider: UIActivityItemProvider {
    var historyItem: HistoryItem!

    override init(historyItem item: HistoryItem) {
        super.init(placeholderItem: "")
        
        historyItem = item
    
    }


    override func item() -> Any {
        DebugLog("activityType = %@", self.activityType)
        if self.activityType == UIActivityTypeMail {
            return NSLocalizedString("I discovered this was a '\(historyItem.title)' with TapTapSee.  Download on iTunes: \("http://goo.gl/QzFA1i")", comment: "")
        }
        else if self.activityType == UIActivityTypePostToTwitter {
            return NSLocalizedString("I discovered this was a '\(historyItem.title)' - @TapTapSee \("http://goo.gl/jZF2FG")", comment: "")
        }
        else if self.activityType == UIActivityTypePostToFacebook {
            return NSLocalizedString("I discovered this was a '\(historyItem.title)' with TapTapSee.  Download on iTunes: \("http://goo.gl/9l3JH4")", comment: "")
        }
        else if self.activityType == UIActivityTypeMessage {
            return NSLocalizedString("I discovered this was a '\(historyItem.title)' with TapTapSee.  Download on iTunes: \("http://goo.gl/5T6Wsu")", comment: "")
        }
        else if self.activityType == UIActivityTypeSaveToCameraRoll {
            var tiffMetadata = [AnyHashable: Any]()
            tiffMetadata[(kCGImagePropertyTIFFImageDescription as? String)] = historyItem.title
            var metadata = [AnyHashable: Any]()
            metadata[(kCGImagePropertyTIFFDictionary as? String)] = tiffMetadata
            var library = ALAssetsLibrary()
            library.writeImage(toSavedPhotosAlbum: historyItem.image.cgImage, metadata: metadata, completionBlock: {(_ assetURL: URL, _ error: Error) -> Void in
                if error != nil {
                    DebugLog("errors: %@", error)
                }
                else {
                    DebugLog("write finished: %@", assetURL)
                }
            })
            return nil
        }

        return NSLocalizedString("I discovered this was a '\(historyItem.title)' with TapTapSee.  Download on iTunes: \()", comment: "")
    }
}
import ImageIO
import AssetsLibrary