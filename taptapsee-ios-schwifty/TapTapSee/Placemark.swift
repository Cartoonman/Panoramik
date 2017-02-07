//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  Placemark.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import Foundation
import CoreLocation
let SER_KEY_LATITUDE = "latitude"
let SER_KEY_LONGITUDE = "longitude"
let SER_KEY_COORDINATE_ACCURACY = "coordinateAccuracy"
let SER_KEY_ALTITUDE = "altitude"
let SER_KEY_ALTITUDE_ACCURACY = "altitudeAccuracy"
let SER_KEY_HEADING = "heading"
let SER_KEY_HEADING_ACCURACY = "headingAccuracy"
class Placemark: NSObject {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var coordinateAccuracy: Double = 0.0
    var altitude: Double = 0.0
    var altitudeAccuracy: Double = 0.0
    var heading: Double = 0.0
    var headingAccuracy: Double = 0.0

    func toQueryStringValue() -> String {
        return "\(self.latitude()),\(self.longitude()),\(self.coordinateAccuracy()),\(self.altitude),\(self.altitudeAccuracy())"
    }

    func coordinatesAsISO6709String() -> String {
        var latFormatter = NumberFormatter()
        latFormatter.numberStyle = .decimal
        latFormatter.positivePrefix = "+"
        latFormatter.minimumIntegerDigits = 2
        latFormatter.minimumFractionDigits = 5
        var lngFormatter = NumberFormatter()
        lngFormatter.numberStyle = .decimal
        lngFormatter.positivePrefix = "+"
        lngFormatter.minimumIntegerDigits = 3
        lngFormatter.minimumFractionDigits = 5
        var formattedStr: String = "\(latFormatter.string(fromNumber: Int(self.latitude)))\(lngFormatter.string(fromNumber: Int(self.longitude)))/"
        return formattedStr
    }

    func toCLLocation() -> CLLocation {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        var location = CLLocation(coordinate: coordinate, altitude: self.altitude, horizontalAccuracy: self.coordinateAccuracy, verticalAccuracy: self.coordinateAccuracy, timestamp: Date(timeIntervalSinceNow: 0))
        return location
    }

    convenience init(dictionary dict: [AnyHashable: Any]) {
        self.init()
        
        self.latitude = (dict[SER_KEY_LATITUDE] as? String)?.doubleValue
        self.longitude = (dict[SER_KEY_LONGITUDE] as? String)?.doubleValue
        self.coordinateAccuracy = (dict[SER_KEY_COORDINATE_ACCURACY] as? String)?.doubleValue
        self.altitude = (dict[SER_KEY_ALTITUDE] as? String)?.doubleValue
        self.altitudeAccuracy = (dict[SER_KEY_ALTITUDE_ACCURACY] as? String)?.doubleValue
        self.heading = (dict[SER_KEY_HEADING] as? String)?.doubleValue
        self.headingAccuracy = (dict[SER_KEY_HEADING_ACCURACY] as? String)?.doubleValue
    
    }

    func encode(withDictionary dict: [AnyHashable: Any]) {
        dict[SER_KEY_LATITUDE] = Int(self.latitude)
        dict[SER_KEY_LONGITUDE] = Int(self.longitude)
        dict[SER_KEY_COORDINATE_ACCURACY] = Int(self.coordinateAccuracy)
        dict[SER_KEY_ALTITUDE] = Int(self.altitude)
        dict[SER_KEY_ALTITUDE_ACCURACY] = Int(self.altitudeAccuracy)
        dict[SER_KEY_HEADING] = Int(self.heading)
        dict[SER_KEY_HEADING_ACCURACY] = Int(self.headingAccuracy)
    }


    override func description() -> String {
        return "(\(self.latitude()), \(self.longitude())) @\(self.coordinateAccuracy()), alt:\(self.altitude) @\(self.altitudeAccuracy()), heading:\(self.heading) @\(self.headingAccuracy)"
    }
// MARK: Serialization
}