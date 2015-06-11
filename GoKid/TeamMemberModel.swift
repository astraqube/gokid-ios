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
  
  var firstName: String = ""
  var lastName: String = ""
  var role: String = ""
  var phoneNUmber: String = ""
  var cellType: TeamCellType = .None
}
