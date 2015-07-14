//
//  RiderModel.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class RiderModel: NSObject {
    var riderID = 0
    var phoneNumber: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var role: String = ""
    var thumURL: String = ""
    var pickupLocation = Location()
    var dropoffLocation = Location()
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        thumURL = json["avatar"]["thumb_url"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        riderID = json["id"].intValue
        email = json["email"].stringValue
        role = json["role"].stringValue

        pickupLocation = Location(json: json["pickup_address"])
        dropoffLocation = Location(json: json["dropoff_address"])
    }
}
