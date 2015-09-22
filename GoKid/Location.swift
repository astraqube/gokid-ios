//
//  Location.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON

typealias GeoCompletion = ((CLLocationDegrees, CLLocationDegrees)->())

class Location: NSObject {
    var name: String = ""
    var long: CLLocationDegrees = 0.0
    var lati: CLLocationDegrees = 0.0
    var stopID = "0"
    
    override init() {
        super.init()
    }
    
    init(name: String, long: Double, lati: Double) {
        self.name = String(name)
        self.long = long
        self.lati = lati
    }
    
    init(json: JSON) {
        self.name = json["display"].stringValue
        self.long = json["longitude"].doubleValue
        self.lati = json["latitude"].doubleValue
    }
    
    func makeCopy() -> Location {
        return Location(name: name, long: long, lati: lati)
    }
    
    func toJson() -> NSDictionary {
        let json = [
            "display": name,
            "longitude": long,
            "latitude": lati
        ]
        return json
    }

    class func geoCodeAddress(address: String, comp: GeoCompletion) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (obj, err)  in
            if let pms = obj as [CLPlacemark]? {
                if pms.count >= 1 {
                    let coor = pms[0].location!.coordinate
                    comp(coor.longitude, coor.latitude)
                    return
                }
            }
            print("Unable to geocode address: \(address). Error: \(err!.description)")
        }
    }

}