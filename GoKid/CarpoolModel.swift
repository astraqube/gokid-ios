//
//  CarpoolModel.swift
//  
//
//  Created by Bingwen Fu on 6/11/15.
//
//

import UIKit

enum CarpoolMode: String {
    case None = ""
    case PickupOnly = "pickup"
    case DropoffOnly = "dropoff"

    static let allValues = [None.rawValue, PickupOnly.rawValue, DropoffOnly.rawValue]
}

class CarpoolModel: NSObject {
    
    var occurence: [Int]?
    var endDate: NSDate?
    var startDate: NSDate?
    var pickUpTime: NSDate?
    var dropOffTime: NSDate?
    
    var startLocation: String?
    var endLocation: String?

    var oneWay: CarpoolMode! = .None

    var riders = [RiderModel]()

    var _kidName = ""
    var kidName : String {
        set { _kidName = newValue }
        get {
            if riders.count > 0 {
                return riders.first!.firstName
            } else {
                return _kidName
            }
        }
    }

    var name = ""
    var id = 0

    var descriptionString : String {
        return "\(name) for \(kidName)"
    }


    private var _isOwner = false
    var isOwner : Bool {
        return _isOwner
    }

    override init() {
        super.init()
    }
    
    init(json: JSON) {
        super.init()
        reflect(json)
    }

    func reflect(json: JSON) {
        name = json["name"].stringValue
        id = json["id"].intValue

        _isOwner = json["is_owner"].boolValue

        var schedule = json["schedule"]
        startDate = parseDate(schedule, key: "starts_at")
        endDate = parseDate(schedule, key: "ends_at")

        if json["rider_ids"] != nil {
            var riderIDs = [Int]()
            for (index: String, value: JSON) in json["rider_ids"] {
                riderIDs.append(value.intValue)
            }
            riders = RiderModel.ridersForRiderIDs(riderIDs)

        } else if json["riders"] != nil {
            riders = RiderModel.arrayOfRidersWithJSON(json["riders"])
        }
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

    func toJson() -> NSDictionary {
        var json = [
            "name": name,
            "schedule": toSchedule()
        ]

        if oneWay.rawValue != "" {
            json["one_way"] = oneWay.rawValue
        }

        if _kidName != "" {
            json["kids"] = [[
                "first_name": _kidName,
                "last_name": UserManager.sharedInstance.info.lastName
            ]]
        }

        return ["carpool": json]
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
