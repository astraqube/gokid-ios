//
//  TeamMemberModel.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

enum TeamCellType {
    case AddUser, AddMember, EditMember, EditUser, None
}

class TeamMemberModel: NSObject {
    
    var cellType: TeamCellType = .None
    var phoneNumber: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var passWord: String = ""
    var email: String = ""
    var role: String = ""
    var thumURL: String = ""
    var teamID: Int = 0
    var userID: Int = 0
    var permissionID: Int = 0
    
    override init() {
        // do nothing
    }
    
    init(json: JSON) {
        var user = json["user"]
        thumURL = user["avatar"]["thumb_url"].stringValue
        firstName = user["first_name"].stringValue
        lastName = user["last_name"].stringValue
        permissionID = json["id"].intValue
        email = user["email"].stringValue
        role = user["role"].stringValue
        userID = user["id"].intValue
    }
    
    
    class func arrayOfMembers(json: JSON) -> [TeamMemberModel] {
        println(json)
        var arr = [TeamMemberModel]()
        for (index: String, subJson: JSON) in json {
            if index == "0" { continue } // ommit owner itself
            var member = TeamMemberModel(json: subJson)
            member.cellType = .EditMember
            arr.append(member)
        }
        return arr
    }
}
