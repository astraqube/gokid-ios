//
//  CarpoolModel.swift
//  
//
//  Created by Bingwen Fu on 6/11/15.
//
//

import UIKit

class CarpoolModel: NSObject {
    
    var occurence: [Int]?
    var endDate: NSDate?
    var startDate: NSDate?
    var pickUpTime: NSDate?
    var dropOffTime: NSDate?
    
    var startLocation: String?
    var endLocation: String?
    
    var riders = [RiderModel]()
    
    var kidName = ""
    var name = ""
    var id = 0
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        super.init()
        name = json["name"].stringValue
        id = json["id"].intValue
        var schedule = json["schedule"]
        startDate = parseDate(schedule, key: "starts_at")
        endDate = parseDate(schedule, key: "ends_at")
        riders = RiderModel.arrayOfRidersWithJSON(json["riders"])
    }

    func parseDate(json: JSON, key: String) -> NSDate? {
        if let dateStr = json[key].string {
            if let date = NSDate.dateFromIso8601String(dateStr) {
                return date
            }
        }
        return nil
    }
    
    class func arrayOfCarpoolsFromJSON(json: JSON) -> [CarpoolModel] {
        var arr = [CarpoolModel]()
        for (index: String, subJson: JSON) in json {
            var carpool = CarpoolModel(json: subJson)
            arr.append(carpool)
        }
        return arr
    }
    
    func toSchedule() -> NSDictionary {
        var schedule: NSMutableDictionary = [
            "dropoff_at": dropOffTime!.iso8601String(),
            "pickup_at": pickUpTime!.iso8601String(),
            "starts_at": startDate!.iso8601String(),
            "time_zone": "Pacific Time (US & Canada)",
        ]

        if occurence != nil && occurence?.isEmpty == false {
            schedule.setValue(endDate!.iso8601String(), forKey: "ends_at")
            schedule.setValue(occurence!, forKey: "days_occurring")
        } else {
            schedule.setValue(startDate!.iso8601String(), forKey: "ends_at")
        }

        return schedule
    }

    func isValidForTime() -> Bool {
        if occurence != nil && endDate != nil && startDate != nil &&
        pickUpTime != nil && dropOffTime != nil {
            return true
        } else {
            return false
        }
    }
    
    func isValidForLocation() -> Bool {
        if startLocation != nil && endLocation != nil {
            return true
        }
        return false
    }
}
