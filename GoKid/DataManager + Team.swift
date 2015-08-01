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
            println(json)
            var members =  TeamMemberModel.arrayOfMembers(json["permissions"])
            self.userManager.teamMembers = members
            comp(true, "")
        }) { (op, error) in
            println("getTeamMembersOfTeam failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateTeamAddress(address: String, address2: String, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)"
        var map = [
            "team": [
                "address": address,
                "address2": address2
            ]
        ]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateTeamAddress success")
            self.userManager.address = address
            self.userManager.address2 = address2
            comp(true, "")
        }) { (op, error) in
            println("updateTeamAddress failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func upLoadTeamMemberImage(image: UIImage, model: TeamMemberModel, comp: completion) {
        
        var urlStr = baseURL + "/api/users/" + String(model.userID) + "/upload"
        var url = NSURL(string: urlStr)!
        var imageData = UIImageJPEGRepresentation(image, 1.0)
        var token = userManager.userToken
        
        var request = NSMutableURLRequest(URL: url)
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token " + token, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        request.HTTPBody = imageData
        
        var op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.setCompletionBlockWithSuccess({ (op, obj) in
            println("succeess to upload team member image")
            var json = JSON(obj)
            model.thumURL = json["avatar"]["thumb_url"].stringValue
            self.imageManager.removeDiskCacheForURL(model.thumURL)
            comp(true, "")
        }, failure: { (op, error) in
            println("fail to upload team member image")
            self.handleRequestError(op, error: error, comp: comp)
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }

    
    func addTeamMember(model: TeamMemberModel, comp: ObjectCompletion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)/permissions"
        
        var permission = [
            "first_name": model.firstName,
            "last_name": model.lastName,
            "role": model.role.lowercaseString
        ]
        if model.phoneNumber != "" {
            permission["phone_number"] = model.phoneNumber
        }
        var map = ["permission" : permission]
        println(map)
        
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("addTeamMember success")
            var newModel = TeamMemberModel(json: JSON(obj)["permission"])
            comp(true, "", newModel)
        }) { (op, error) in
            println("addTeamMember failed")
            self.handleUserResuestError(op, error: error, comp: comp)
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
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateTeamMember(model: TeamMemberModel, comp: ObjectCompletion) {
        var url = baseURL + "/api/users/" + String(model.userID)
        var user = [
            "first_name": model.firstName,
            "last_name" : model.lastName,
            "role": model.role.lowercaseString
        ]
        if model.phoneNumber != "" {
            user["phone_number"] = model.phoneNumber
        } else {
            user["phone_number"] = nil
        }        
        var map = ["user" : user]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateTeamMember success")
            comp(true, "", model)
        }) { (op, error) in
            println("updateTeamMember failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }
}

