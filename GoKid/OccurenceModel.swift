//
//  OccurenceModel.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

import UIKit
import CoreLocation

enum CalendarCellType {
    case Notification, Time, Normal, Add, None
}

enum OccurenceType: String {
    case Pickup = "Pickup"
    case Dropoff = "Drop-off"
}

class OccurenceModel: NSObject {
    var taken: Bool {
        return volunteer != nil
    }
    var poolDriverName: String {
        return volunteer != nil ? volunteer!.firstName : "No Driver yet"
    }
    var poolDriverImageUrl: String {
        return volunteer != nil ? volunteer!.imageURL : ""
    }
    var poolDriverPhoneNum = ""
    var volunteer : VolunteerModel?
    var carpool : CarpoolModel!

    var poolType = ""
    var poolname: String {
        return carpool.name
    }
    var occursAt: NSDate?
    
    var eventLocation = Location()
    var defaultLocation = Location()
    
    var cellType: CalendarCellType = .None
    var pooltimeStr = ""
    ///this is a localized date string 'today' or 'tomorrow'
    var occursAtStr = ""
    var notification = ""
   
    var riders = [RiderModel]()

    var occurenceID = 0
    var carpoolID : Int {
        return carpool.id
    }

    var rideString : String {
        return "\(poolType) at \(pooltimeStr)"
    }

    override init() {
        super.init()
    }

    init(occurence: JSON) {
        super.init()
        reflect(occurence)
    }

    func reflect(occurence: JSON) {
        occursAt = parseDate(occurence, key: "occurs_at")
        cellType = .Normal
        occurenceID = occurence["id"].intValue
        poolType = occurence["kind"].stringValue

        if let carpoolJSON = occurence["carpool"] as JSON? {
            carpool = CarpoolModel(json: carpoolJSON)
        }

        volunteer = occurence["volunteer"] != nil ? VolunteerModel(json: occurence["volunteer"]) : nil

        if occurence["rider_ids"] != nil {
            var riderIDs = [Int]()
            for (index: String, value: JSON) in occurence["rider_ids"] {
                riderIDs.append(value.intValue)
            }
            riders = RiderModel.ridersForRiderIDs(riderIDs)
            
        } else if occurence["riders"] != nil {
            riders = RiderModel.arrayOfRidersWithJSON(occurence["riders"])
        }

        eventLocation = Location(json: occurence["event_location"])
        defaultLocation = Location(json: occurence["default_address"])
        generateOtherField()
    }
    
    class func arrayOfEventsFromOccurrences(json: JSON) -> [OccurenceModel] {
        var arr = [OccurenceModel]()
        for (index: String, subJson: JSON) in json {
            var carpool = OccurenceModel(occurence: subJson)
            arr.append(carpool)
        }
        return arr
    }
    
    init(fakeList: JSON) {
        super.init()
        cellType = .Normal
        occursAt = parseDate(fakeList, key: "occurs_at")
        poolType = fakeList["kind"].stringValue
        generateOtherField()
    }
    
    func generateOtherField() {
        if let date = occursAt {
            occursAtStr = date.dateString()
            pooltimeStr = date.timeString()
            var today = NSDate()
            var tomorrow = today.dateByAddingTimeInterval(60*60*24)
            if occursAtStr == today.dateString() {
                occursAtStr = "Today"
            }
            if occursAtStr == tomorrow.dateString() {
                occursAtStr = "Tomorrow"
            }
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
    
    func poolTimeStringWithSpace() -> String {
        var str = String(pooltimeStr)
        str = str.replace("am", " am")
        str = str.replace("pm", " pm")
        return str
    }
}
