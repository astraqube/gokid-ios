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
        var startTime = "12.00 pm"
        var endTime = "1.00 pm"
        
        if let str = userManager.currentChoosenDate { date = str }
        if let str = userManager.currentChoosenEndTime { endTime = str }
        if let str = userManager.currentChossenStartTime { startTime = str }
        
        var str = "Volunteer as Driver"
        var c0 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c1 = VolunteerModel(title: "", time: "April 24, Fri", poolType: "", cellType: .Date)
        var c2 = VolunteerModel(title: str, time: "12.00 pm", poolType: "Drop-off", cellType: .Normal)
        var c3 = VolunteerModel(title: str, time: "1.00 pm", poolType: "Pick-up", cellType: .Normal)
        return [c0, c1, c2, c3]
    }
}
