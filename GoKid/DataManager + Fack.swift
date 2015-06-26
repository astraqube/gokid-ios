//
//  DataManager Fack.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

extension DataManager {
    
    func fakeCalendarData() -> [CalendarModel] {
        var c1 = CalendarModel()
        c1.cellType = .Notification
        c1.notification = "Hey Liz you are driving on monday"
        
        var c2 = CalendarModel()
        c2.poolDateStr = "April 5 Friday"
        c2.cellType = .Time
        
        var c3 = CalendarModel()
        c3.cellType = .Normal
        c3.poolname = "Soccer Practice"
        c3.poolType = "DROP OFF"
        c3.pooltimeStr = "12.00pm"
        c3.poolDriver = "No driver yet"
        
        
        var c4 = CalendarModel()
        c4.cellType = .Normal
        c4.poolname = "Soccer Practice"
        c4.poolType = "PICK UP"
        c4.pooltimeStr = "1.00pm"
        c4.poolDriver = "No driver yet"
        
        var c5 = CalendarModel()
        c5.cellType = .Add
        
        return [c1, c2, c3, c4, c5]
    }
    
    func fakeVolunteerData() -> [VolunteerModel] {
        var date = "April 24, Fri"
        var pickupTime = "12.00 pm"
        var dropoffTime = "1.00 pm"
        
        var model = userManager.currentCarpoolModel
        if let str = model.startDate?.dateString() { date = str }
        if let str = model.pickUpTime?.timeString() { pickupTime = str }
        if let str = model.dropOffTime?.timeString() { dropoffTime = str }
        
        var str = "Volunteer as Driver"
        var c0 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c1 = VolunteerModel(title: "", time: date, poolType: "", cellType: .Date)
        var c2 = VolunteerModel(title: str, time: dropoffTime, poolType: "Drop-off", cellType: .Normal)
        var c3 = VolunteerModel(title: str, time: pickupTime, poolType: "Pick-up", cellType: .Normal)
        
        if userManager.volunteerEvents.count >= 2 {
            var v0 = userManager.volunteerEvents[0]
            var v1 = userManager.volunteerEvents[1]
            
            c3.carpoolID = v0.carpoolID
            c3.occrenceID = v0.occrencID
            
            c2.carpoolID = v1.carpoolID
            c2.occrenceID = v1.occrencID
        }
        
        return [c0, c1, c2, c3]
    }
}
