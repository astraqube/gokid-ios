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

struct DaySchedule {
    var dayNum: Int!
    var oneWay: CarpoolMode?
    var pickUpTime: NSDate?
    var dropOffTime: NSDate?
    var endDate: NSDate?
    var startDate: NSDate?

    func toJson() -> NSDictionary {
        var json: [String: AnyObject] = [
            "starts_at": startDate!.iso8601String(),
            "ends_at": endDate!.iso8601String(),
            "time_zone": "Pacific Time (US & Canada)"
        ]

        if oneWay?.rawValue != "" {
            json["one_way"] = oneWay!.rawValue
        }

        if pickUpTime != nil {
            json["pickup_at"] = pickUpTime!.iso8601String()
        }

        if dropOffTime != nil {
            json["dropoff_at"] = dropOffTime!.iso8601String()
        }

        return json
    }
}

class CarpoolModel: NSObject {
    
    var endDate: NSDate?
    var startDate: NSDate?
    var pickUpTime: NSDate?
    var dropOffTime: NSDate?
    var oneWay: CarpoolMode?

    var startLocation: String?
    var endLocation: String?

    var schedules: [DaySchedule]!

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
        var json: [String: AnyObject] = [
            "name": name
        ]

        if _kidName != "" {
            json["kids"] = [[
                "first_name": _kidName,
                "last_name": UserManager.sharedInstance.info.lastName
            ]]
        }

        if schedules != nil && !schedules.isEmpty {
            var scheduleDict = [String: NSDictionary]()
            for sched in schedules {
                scheduleDict[sched.dayNum.description] = sched.toJson()
            }
            json["schedules"] = scheduleDict
        } else {
            json["schedule"] = toSchedule()
        }

        return ["carpool": json]
    }

    func toSchedule() -> NSDictionary {
        var schedule: [String: AnyObject] = [
            "dropoff_at": dropOffTime!.iso8601String(),
            "pickup_at": pickUpTime!.iso8601String(),
            "starts_at": startDate!.iso8601String(),
            "ends_at": endDate!.iso8601String(),
            "time_zone": "Pacific Time (US & Canada)",
        ]

        if oneWay?.rawValue != "" {
            schedule["one_way"] = oneWay!.rawValue
        }

        return schedule
    }

}
