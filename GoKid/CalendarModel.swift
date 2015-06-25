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
    var poolType = ""
    var poolname = ""
    var poolDate: NSDate?
    
    var cellType: CalendarCellType = .None
    var pooltimeStr = ""
    var poolDateStr = ""
    var notification = ""
    
    override init() {
        super.init()
    }
    
    init(occurence: JSON) {
        super.init()
        poolDate = parseDate(occurence, key: "occurs_at")
        poolname = occurence["carpool"]["name"].stringValue
        poolType = occurence["kind"].stringValue
        cellType = .Normal
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
        
        poolDriver = "No Driver yet"
        
        if let date = poolDate {
            var df = NSDateFormatter()
            df.dateFormat = "EEEE MMMM d, YYYY"
            pooltimeStr = df.stringFromDate(date)
            df.dateFormat = "hh:mma"
            pooltimeStr = df.stringFromDate(date).lowercaseString
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
