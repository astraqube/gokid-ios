//
//  TeamMemberModel.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import SwiftyJSON

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
    var teams: [Int]?
    var userID: Int = 0
    var permissionID: Int = 0
    var isCurrentUser: Bool = false

    var fullName: String {
        return "\(firstName) \(lastName)"
    }

    override init() {
        super.init()
    }
    
    init(json: JSON) {
        var user = json["user"]
        thumURL = user["avatar"]["thumb_url"].stringValue
        firstName = user["first_name"].stringValue
        lastName = user["last_name"].stringValue
        permissionID = json["id"].intValue
        email = user["email"].stringValue
        phoneNumber = user["phone_number"].stringValue
        role = user["role"].stringValue
        userID = user["id"].intValue
        isCurrentUser = user["is_current_user"].boolValue
        teams = json["team_ids"].arrayObject as? [Int]
    }

    class func arrayOfMembers(json: JSON) -> [TeamMemberModel] {
        var arr = [TeamMemberModel]()
        for (_, subJson): (String, JSON) in json {
            let member = TeamMemberModel(json: subJson)

            if member.isCurrentUser {
                let um = UserManager.sharedInstance
                um.updateUserWithTeamMembersInfo(subJson["user"])
            } else {
                member.cellType = .EditMember
                arr.append(member)
            }
        }
        return arr
    }
}
