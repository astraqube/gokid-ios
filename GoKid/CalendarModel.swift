//
//  CalendarModel.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

import UIKit

enum CalendarCellType {
    case Notification, Time, Normal, Add, None
}

class CalendarModel: NSObject {

    var poolDriver = ""
    var poolDriverImageUrl = ""
    
    var poolType = ""
    var poolname = ""
    var poolDate: NSDate?
    
    var cellType: CalendarCellType = .None
    var pooltimeStr = ""
    var poolDateStr = ""
    var notification = ""
   
    var occrencID = 0
    var carpoolID = 0
    
    override init() {
        super.init()
    }
    
    init(occurence: JSON) {
        super.init()
        poolDate = parseDate(occurence, key: "occurs_at")
        poolname = occurence["carpool"]["name"].stringValue
        poolType = occurence["kind"].stringValue
        cellType = .Normal
        carpoolID = occurence["carpool"]["id"].intValue
        occrencID = occurence["id"].intValue
        poolDriver = occurence["volunteer"]["first_name"].stringValue
        poolDriverImageUrl = occurence["volunteer"]["avatar"]["thumb_url"].stringValue
        generateOtherField()
    }
    
    class func arrayOfEventsFromOccurrences(json: JSON) -> [CalendarModel] {
        var arr = [CalendarModel]()
        for (index: String, subJson: JSON) in json {
            var carpool = CalendarModel(occurence: subJson)
            arr.append(carpool)
        }
        return arr
    }
    
    func generateOtherField() {
        if poolType == "pickup" { poolType = "PICK UP" }
        else if poolType == "dropoff" { poolType = "DROP OFF" }
        else { poolType = "Unknown type" }
        
        if poolDriver == "" {
            poolDriver = "No Driver yet"
        }
        
        if let date = poolDate {
            poolDateStr = date.dateString()
            pooltimeStr = date.timeString()
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
}
