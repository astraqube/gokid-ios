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
    
    var cellType: CalendarCellType = .None
    var notification = ""
    
    var pooltime = ""
    var poolType = ""
    var poolname = ""
    var poolDriver = ""
    
    var date = ""
}
