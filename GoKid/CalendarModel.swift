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
}

class CalendarModel: NSObject {

    var taken = false
    var poolDriverName = ""
    var poolDriverImageUrl = ""
    var poolDriverPhoneNum = ""
    
    var poolType = ""
    var poolname = ""
    var poolDate: NSDate?
    
    var poolLocation = Location()
    
    var cellType: CalendarCellType = .None
    var pooltimeStr = ""
    var poolDateStr = ""
    var notification = ""
   
    var occurenceID = 0
    var carpoolID = 0

    override init() {
        super.init()
    }
    
    init(occurence: JSON) {
        super.init()
        poolDate = parseDate(occurence, key: "occurs_at")
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
    
    class func arrayOfEventsFromOccurrences(json: JSON) -> [CalendarModel] {
        var arr = [CalendarModel]()
        for (index: String, subJson: JSON) in json {
            var carpool = CalendarModel(occurence: subJson)
            arr.append(carpool)
        }
        return arr
    }
    
    init(fakeList: JSON) {
        super.init()
        cellType = .Normal
        poolDate = parseDate(fakeList, key: "occurs_at")
        poolType = fakeList["kind"].stringValue
        generateOtherField()
    }
    
    func generateOtherField() {
        //if poolType == "pickup" { poolType = "PICK UP" }
        //else if poolType == "dropoff" { poolType = "DROP OFF" }
        //else { poolType = "Unknown type" }
        
        if poolDriverName == "" {
            poolDriverName = "No Driver yet"
        }
        if let date = poolDate {
            poolDateStr = date.dateString()
            pooltimeStr = date.timeString()
            var today = NSDate()
            var tomorrow = today.dateByAddingTimeInterval(60*60*24)
            if poolDateStr == today.dateString() {
                poolDateStr = "Today"
            }
            if poolDateStr == tomorrow.dateString() {
                poolDateStr = "Tomorrow"
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
