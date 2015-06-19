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
    
}
