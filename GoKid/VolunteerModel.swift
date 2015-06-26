//
//  VolunteerModel.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

enum VOCellType {
    case Normal
    case Date
    case Empty
}

class VolunteerModel: NSObject {
    
    var timeString = ""
    var titleString = ""
    var poolTypeString = ""
    var cellType: VOCellType = .Empty
    var taken = false
    var occrenceID = 0
    var carpoolID = 0
    
    init(title: String, time: String, poolType: String, cellType: VOCellType) {
        self.poolTypeString = poolType
        self.titleString = title
        self.timeString = time
        self.cellType = cellType
        self.taken = false
        super.init()
    }
}
