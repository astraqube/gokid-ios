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
    var id: Int = 0
    
    
    class func arrayOfMembers(json: JSON) -> [TeamMemberModel] {
        var arr = [TeamMemberModel]()
        for (index: String, subJson: JSON) in json {
            if index == "0" { continue } // ommit owner itself
            var user = subJson["user"]
            var member = TeamMemberModel()
            member.id = subJson["id"].intValue
            member.firstName = user["first_name"].stringValue
            member.lastName = user["last_name"].stringValue
            member.email = user["email"].stringValue
            member.role = user["role"].stringValue
            member.cellType = .EditMember
            arr.append(member)
        }
        return arr
    }
}
