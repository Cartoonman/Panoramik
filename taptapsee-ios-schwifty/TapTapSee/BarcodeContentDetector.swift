//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  BarcodeContentDetector.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import CoreMedia
class BarcodeContentDetector: NSObject, UPCDatabaseDelegate, ISBNDatabaseDelegate {
    var featureDescription: String = ""
    var featureType: String = ""

    weak var delegate: BarcodeContentDetectorDelegate?

    override init(delegate: Any, withFeatureType type: String, withFeatureDescription description: String) {
        super.init()
        
        self.delegate = delegate
        featureType = type
        featureDescription = description
    
    }

    override func start() {
            // Check to see if it's a URL
        var urlFromData: String = self.extractUrl(featureDescription)
        if urlFromData != nil {
            // TODO: mark as a URL so we can do a webview
        }
        // If it begins with 978 and it's an EAN-13 it might be an ISBN encoded as an EAN-13
        if ISBNDatabase.canRecognizeType(featureType, withCode: featureDescription) {
            var isbnDB = ISBNDatabase(query: featureDescription)
            isbnDB.delegate = self
            isbnDB.start()
        }
        else if UPCDatabase.canRecognizeType(featureType, withCode: featureDescription) {
            var upcDB = UPCDatabase(query: featureDescription)
            upcDB.delegate = self
            upcDB.start()
        }
        else {
            self.delegate.barcodeContentDetector(self, didIdentifyWith: featureDescription)
        }

    }


    func extractUrl(_ candidate: String) -> String {
        var linkDetector = try? NSDataDetector(types: .link)
        var matches: [Any] = linkDetector?.matches(in: candidate, options: [], range: NSRange(location: 0, length: (candidate.characters.count ?? 0)))
        for match: NSTextCheckingResult in matches {
            if match.resultType == .link {
                var url: URL? = match.url
                return url?.absoluteString!
            }
        }
        return nil
    }
// MARK: UPCDatabase delegate

    func upcDatabase(_ db: UPCDatabase, didFindProduct name: String) {
        self.delegate.barcodeContentDetector(self, didIdentifyWith: name)
    }

    func upcDatabase(_ db: UPCDatabase, didFinishWithError error: Error?) {
        // Ignore error and return default response (upc)
        self.delegate.barcodeContentDetector(self, didIdentifyWith: featureDescription)
    }
// MARK: ISBNDatabase delegate

    func isbnDatabase(_ db: ISBNDatabase, didFindProduct name: String) {
        self.delegate.barcodeContentDetector(self, didIdentifyWith: name)
    }

    func isbnDatabase(_ db: ISBNDatabase, didFinishWithError error: Error?) {
        // Ignore error and return default response (upc)
        self.delegate.barcodeContentDetector(self, didIdentifyWith: featureDescription)
    }
}