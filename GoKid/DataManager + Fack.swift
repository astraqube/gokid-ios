//
//  DataManager Fack.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

extension DataManager {
    
    func fackCalendarData() -> [CalendarModel] {
        var c1 = CalendarModel()
        c1.cellType = .Notification
        c1.notification = "Hey Liz you are driving on monday"
        
        var c2 = CalendarModel()
        c2.date = "April 5 Friday"
        c2.cellType = .Time
        
        var c3 = CalendarModel()
        c3.cellType = .Normal
        c3.poolname = "Soccer Practice"
        c3.poolType = "DROP OFF"
        c3.pooltime = "12.00pm"
        c3.poolDriver = "No driver yet"
        
        
        var c4 = CalendarModel()
        c4.cellType = .Normal
        c4.poolname = "Soccer Practice"
        c4.poolType = "PICK UP"
        c4.pooltime = "1.00pm"
        c4.poolDriver = "No driver yet"
        
        var c5 = CalendarModel()
        c5.cellType = .Add
        
        return [c1, c2, c3, c4, c5]
    }
}
