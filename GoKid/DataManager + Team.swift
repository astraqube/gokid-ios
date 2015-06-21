//
//  DataManager + Team.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


extension DataManager {
    
    func getTeamMembersOfTeam(comp: completion) {
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
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        }
    }
    
    func addTeamMember(model: TeamMemberModel, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)/permissions"
        var map = [
            "permission": [
                "first_name": model.firstName,
                "last_name": model.lastName,
                "email": "aadsdsdss@ddd.com" + model.lastName, // will change we backend is ready.......
                "role": model.role.lowercaseString
            ]
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            println(obj)
            comp(true, "")
        }) { (op, error) in
            println("addTeamMember failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        }
    }
    
    func deleteTeamMember(id: Int, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)/permissions/\(id)"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("deleteTeamMember success")
            comp(true, "")
        }) { (op, error) in
            println("deleteTeamMember failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        }
    }
    
    func updateTeamMember(model: TeamMemberModel, comp: completion) {
        var url = baseURL + "/api/sessions"
        var map = [
            "" : ""
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            comp(true, "")
        }) { (op, error) in
            println("addTeamMember failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        }
    }
}

