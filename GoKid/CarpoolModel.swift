//
//  CarpoolModel.swift
//  
//
//  Created by Bingwen Fu on 6/11/15.
//
//

import UIKit

class CarpoolModel: NSObject {
    
    var occurence: [Int]?
    var endDate: NSDate?
    var startDate: NSDate?
    var pickUpTime: NSDate?
    var dropOffTime: NSDate?
    
    var kidName = ""
    var name = ""
    var id = 0
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        name = json["carpool"]["name"].stringValue
        id = json["carpool"]["id"].intValue
        super.init()
    }
    
    func isValid() -> Bool {
        if occurence != nil && endDate != nil && startDate != nil &&
        pickUpTime != nil && dropOffTime != nil {
            return true
        } else {
            return false
        }
    }
}
