//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  HistoryItemStore.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import CloudSight
let STR_KEY_HISTORY = "history"
class HistoryItemStore: NSObject {
    var items = [Any]()

    class func shared() -> HistoryItemStore {
        var sharedStore: HistoryItemStore? = nil
        if sharedStore == nil {
            // Skip over alloc override below
            sharedStore = super.alloc(withZone: nil)()
        }
        return sharedStore!
    }

    class func image(forFilename name: String) -> UIImage {
        return UIImage(contentsOfFile: self.fullPath(forImageFilename: name))!
    }

    class func fullPath(forImageFilename name: String) -> String {
        return URL(fileURLWithPath: HistoryItemStore.documentPath()).appendingPathComponent(name).absoluteString
    }

    class func documentPath() -> String {
        var documentDirectories: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var documentDirectory: String = documentDirectories[0]
        return documentDirectory
    }

    class func itemArchivePath() -> String {
        return URL(fileURLWithPath: self.documentPath()).appendingPathComponent(STR_DATADIR).absoluteString
    }

    func removeItem(at index: Int) {
        var item: HistoryItem? = items[index]
        if item == nil {
            return
        }
        self.removeImages(item)
        items.remove(at: index)
        self.saveChanges()
    }

    override func removeItem(_ item: HistoryItem) {
        self.removeImages(item)
        items.remove(at: items.index(of: item) ?? -1)
        self.saveChanges()
    }

    func removeUnfinishedQueries() {
        var itemsToRemove = [Any]() /* capacity: items.count */
        for item: HistoryItem in items {
            if !item.isFound {
                // Cancel CloudSight query if exists
                if item.cloudSightQuery {
                    item.cloudSightQuery.stop()
                }
                // Add to array remove queue
                itemsToRemove.append(item)
            }
        }
        print("Removing \(itemsToRemove.count) unfinished queries")
        items.removeObjects(in: itemsToRemove)
    }

    func createItem(for image: UIImage) -> HistoryItem {
        var item = HistoryItem()
        self.push(item)
        self.save(image, for: item)
        return item
    }

    func createItem(forText text: String) -> HistoryItem {
        var item = HistoryItem()
        item.title = text
        item.isFound = true
        self.push(item)
        return item
    }

    func item(for query: CloudSightQuery) -> HistoryItem {
        for item: HistoryItem in items {
            if item.cloudSightQuery == query {
                return item
            }
        }
        return nil
    }

    func item(forTitle title: String) -> HistoryItem {
        for item: HistoryItem in items {
            if (item.title == title) {
                return item
            }
        }
        return nil
    }

    override func items() -> [Any] {
        return items
    }

    func saveChanges() -> Bool {
        var dict = [AnyHashable: Any]()
        dict[STR_KEY_VERSION] = STR_DATAFILE_VER
        if self.items() {
            var encodedItemsArray = [Any]() /* capacity: items.count */
            for item: HistoryItem in self.items() {
                var queryDictionary = [AnyHashable: Any]()
                item.encode(withDictionary: queryDictionary)
                encodedItemsArray.append(queryDictionary)
            }
            dict[STR_KEY_HISTORY] = encodedItemsArray
        }
        var dataFilePath: String = URL(fileURLWithPath: HistoryItemStore.itemArchivePath()).appendingPathComponent(STR_DATAFILE).absoluteString
        return dict.write(toFile: dataFilePath, atomically: true)
    }


    class func alloc(with zone: NSZone) -> Any {
        return self.shared()
    }

    override init() {
        super.init()
        
        items = [Any]() /* capacity: MAX_ITEMS */
    
    }
// MARK: Path management

    class func createArchivePath() {
        var error: Error? = nil
        if (try? FileManager.default.createDirectory(atPath: self.itemArchivePath(), withIntermediateDirectories: true, attributes: nil)) == false {
            print("Error creating directory \(self.itemArchivePath()): \(error?.localizedDescription)")
        }
    }
// MARK: Items accessors

    func push(_ item: HistoryItem) {
        items.insert(item, at: 0)
        if items.count > MAX_ITEMS {
            self.removeImages(items.last)
            items.removeLast()
        }
    }

    func save(_ image: UIImage, for item: HistoryItem) {
        // Save image as a jpg in the data directory.
        // Also create and save a thumbnail suffixed with "thumb".
        // Update query object with the location of image files.
        HistoryItemStore.createArchivePath()
        var success: Bool = image.save(asJPEGinDirectory: HistoryItemStore.itemArchivePath(), with: item.imageName())
        if !success {
            print("Error saving image: \(HistoryItemStore.itemArchivePath())/\(item.imageName())")
        }
        success = image.save(asJPEGinDirectory: HistoryItemStore.itemArchivePath(), with: item.thumbName(), size: item.thumbSizeInPixels())
        if !success {
            print("Error saving thumbnail: \(HistoryItemStore.itemArchivePath())/\(item.thumbName())")
        }
        item.imageFile = URL(fileURLWithPath: STR_DATADIR).appendingPathComponent(item.imageName()).absoluteString
        item.thumbFile = URL(fileURLWithPath: STR_DATADIR).appendingPathComponent(item.thumbName()).absoluteString
    }

    func removeImages(_ item: HistoryItem) {
        var imagePath: String = URL(fileURLWithPath: HistoryItemStore.documentPath()).appendingPathComponent(item.imageFile).absoluteString
        var thumbPath: String = URL(fileURLWithPath: HistoryItemStore.documentPath()).appendingPathComponent(item.thumbFile).absoluteString
        var fileManager = FileManager.default
        var error: Error? = nil
        if item.imageFile && !(item.imageFile == "") {
            var success: Bool? = try? fileManager.removeItem(atPath: imagePath)
            if success == nil {
                print("Error removing: \(imagePath)")
                print("\(error)")
            }
        }
        if item.thumbFile && !(item.thumbFile == "") {
            var success: Bool? = try? fileManager.removeItem(atPath: thumbPath)
            if success == nil {
                print("Error removing: \(imagePath)")
                print("\(error)")
            }
        }
        item.imageFile = nil
        item.thumbFile = nil
    }
}
let MAX_ITEMS = 5