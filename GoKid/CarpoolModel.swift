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
    
    var kidName = ""
    var name = ""
    var id = 0
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        name = json["carpool"]["name"].stringValue
        id = json["carpool"]["id"].intValue
        super.init()
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
            schedule.setValue(occurence!, forKey: "days_occuring")
        } else {
            // FIXME: strange requirements from the backend
            schedule.setValue(startDate!.iso8601String(), forKey: "ends_at")
            schedule.setValue([3], forKey: "days_occuring")
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
