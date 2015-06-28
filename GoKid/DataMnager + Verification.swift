//
//  DataMnager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/25/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

extension DataManager {
    
    func requestingVerificationCode(phoneNum: String, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)/permissions"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getTeamMembersOfTeam success")
            var json = JSON(obj)
            var members =  TeamMemberModel.arrayOfMembers(json["permissions"])
            self.userManager.teamMembers = members
            comp(true, "")
        }) { (op, error) in
            println("getTeamMembersOfTeam failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
