//
//  DataManager + Team.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


extension DataManager {
    
    typealias UserCompletion = ((Bool, String, TeamMemberModel?)->())
    
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
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        }
    }
    
    func updateTeamAddress(address1: String, address2: String, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)"
        var map = [
            "team": [
                "address": address1,
                "address2": address2
            ]
        ]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateTeamAddress success")
            comp(true, "")
        }) { (op, error) in
            println("updateTeamAddress failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
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
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr)
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }

    
    func addTeamMember(model: TeamMemberModel, comp: UserCompletion) {
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
            var newModel = TeamMemberModel(json: JSON(obj)["permission"])
            comp(true, "", newModel)
        }) { (op, error) in
            println("addTeamMember failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr, nil)
        }
    }
    
    func deleteTeamMember(id: Int, comp: completion) {
        var teamID = String(userManager.info.teamID)
        var url = baseURL + "/api/teams/\(teamID)/permissions/\(id)"
        println(url)
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
    
    func updateTeamMember(model: TeamMemberModel, comp: UserCompletion) {
        var url = baseURL + "/api/users/" + String(model.userID)
        var map = [
            "user": [
                "first_name": model.firstName,
                "last_name" : model.lastName,
                "email": model.email,
                "role": model.role.lowercaseString
            ]
        ]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateTeamMember success")
            comp(true, "", model)
        }) { (op, error) in
            println("updateTeamMember failed")
            var errorStr = self.constructErrorStr(op, error: error)
            comp(false, errorStr, nil)
        }
    }
}

