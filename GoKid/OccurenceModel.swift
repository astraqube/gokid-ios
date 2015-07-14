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

class OccurenceModel: NSObject {
    var taken = false
    var poolDriverName = ""
    var poolDriverImageUrl = ""
    var poolDriverPhoneNum = ""
    
    var poolType = ""
    var poolname = ""
    var occursAt: NSDate?
    
    var poolLocation = Location()
    
    var cellType: CalendarCellType = .None
    var pooltimeStr = ""
    var occursAtStr = ""
    var notification = ""
   
    var riders : [RiderModel]?
    
    var occurenceID = 0
    var carpoolID = 0
    
    override init() {
        super.init()
    }

    init(occurence: JSON) {
        super.init()
        occursAt = parseDate(occurence, key: "occurs_at")
        cellType = .Normal
        occurenceID = occurence["id"].intValue
        poolType = occurence["kind"].stringValue
        carpoolID = occurence["carpool"]["id"].intValue
        poolname = occurence["carpool"]["name"].stringValue
        poolDriverName = occurence["volunteer"]["first_name"].stringValue
        poolDriverImageUrl = occurence["volunteer"]["avatar"]["thumb_url"].stringValue
        poolLocation = Location(json: occurence["locations"][0])
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
        if poolDriverName == "" {
            poolDriverName = "No Driver yet"
        }
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
