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
    
    var startLocation: String?
    var endLocation: String?
    
    var kidName = ""
    var name = ""
    var id = 0
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        println(json)
        name = json["carpool"]["name"].stringValue
        id = json["carpool"]["id"].intValue
        super.init()
    }
    
    func isValidForTime() -> Bool {
        if occurence != nil && endDate != nil && startDate != nil &&
        pickUpTime != nil && dropOffTime != nil {
            return true
        } else {
            return false
        }
    }
    
    func isValidForLocation() -> Bool {
        if startLocation != nil && endLocation != nil {
            return true
        }
        return false
    }
}
