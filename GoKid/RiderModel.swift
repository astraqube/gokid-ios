//
//  RiderModel.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

func ==(lhs: RiderModel, rhs: RiderModel) -> Bool {
    return lhs.riderID == rhs.riderID
}
extension RiderModel : Equatable {}

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
    var teams: [Int]?

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    var isInMyTeam: Bool {
        let currentUser = UserManager.sharedInstance
        return contains(teams!, currentUser.info.teamID)
    }

    static var ridersByID = [ Int : RiderModel]()
    
    class func ridersForRiderIDs(riderIDs : [Int]) -> ([RiderModel]){
        return riderIDs.reduce([RiderModel](), combine: { (acc: [RiderModel], id) -> [RiderModel] in
            if let rider = self.ridersByID[id] {
                return acc + [rider]
            }
            return acc
        })
    }
    
    class func cacheRiders(riders: [RiderModel]) {
        for rider in riders {
            ridersByID[rider.riderID] = rider
        }
    }

    class func arrayOfRidersWithJSON(json: JSON) -> [RiderModel] {
        var arr = [RiderModel]()
        for (index: String, subJson: JSON) in json {
            var rider = RiderModel(json: subJson)
            arr.append(rider)
        }
        return arr
    }
    
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
        phoneNumber = json["phone_number"].stringValue
        teams = json["team_ids"].arrayObject as? [Int]

        pickupLocation = Location(json: json["pickup_address"])
        dropoffLocation = Location(json: json["dropoff_address"])
    }

    func toJson() -> NSDictionary {
        var json: [String: AnyObject] = ["id": riderID]
        if pickupLocation.name != "" {
            json["pickup_address"] = pickupLocation.toJson()
        }
        if dropoffLocation.name != "" {
            json["dropoff_address"] = dropoffLocation.toJson()
        }
        return json
    }

}
