//
//  DataManager + Team.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import SwiftyJSON
import AFNetworking

extension DataManager {
        
    func getTeamMembersOfTeam(comp: completion) {
        let teamID = String(userManager.info.teamID)
        let url = baseURL + "/api/teams/\(teamID)/permissions"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getTeamMembersOfTeam success", terminator: "")
            var json = JSON(obj)
            print(json)
            let members =  TeamMemberModel.arrayOfMembers(json["permissions"])
            self.userManager.teamMembers = members
            comp(true, "")
        }) { (op, error) in
            print("getTeamMembersOfTeam failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateTeamAddress(address: String, address2: String, comp: completion) {
        let teamID = String(userManager.info.teamID)
        let url = baseURL + "/api/teams/\(teamID)"
        let map = [
            "team": [
                "address": address,
                "address2": address2
            ]
        ]
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateTeamAddress success", terminator: "")
            self.userManager.address = address
            self.userManager.address2 = address2
            comp(true, "")
        }) { (op, error) in
            print("updateTeamAddress failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func upLoadTeamMemberImage(image: UIImage, model: TeamMemberModel, comp: completion) {
        
        let urlStr = baseURL + "/api/users/" + String(model.userID) + "/upload"
        let url = NSURL(string: urlStr)!
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let token = userManager.userToken
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token " + token, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        request.HTTPBody = imageData
        
        let op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.setCompletionBlockWithSuccess({ (op, obj) in
            print("succeess to upload team member image", terminator: "")
            var json = JSON(obj)
            model.thumURL = json["avatar"]["thumb_url"].stringValue
            self.imageManager.removeDiskCacheForURL(model.thumURL)
            comp(true, "")
        }, failure: { (op, error) in
            print("fail to upload team member image", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }

    
    func addTeamMember(model: TeamMemberModel, comp: ObjectCompletion) {
        let teamID = String(userManager.info.teamID)
        let url = baseURL + "/api/teams/\(teamID)/permissions"
        
        var permission = [
            "first_name": model.firstName,
            "last_name": model.lastName,
            "role": model.role.lowercaseString
        ]
        if model.phoneNumber != "" {
            permission["phone_number"] = model.phoneNumber
        }
        let map = ["permission" : permission]
        print(map, terminator: "")
        
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("addTeamMember success", terminator: "")
            let newModel = TeamMemberModel(json: JSON(obj)["permission"])
            comp(true, "", newModel)
        }) { (op, error) in
            print("addTeamMember failed", terminator: "")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }
    
    func deleteTeamMember(id: Int, comp: completion) {
        let teamID = String(userManager.info.teamID)
        let url = baseURL + "/api/teams/\(teamID)/permissions/\(id)"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            print("deleteTeamMember success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("deleteTeamMember failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateTeamMember(model: TeamMemberModel, comp: ObjectCompletion) {
        let url = baseURL + "/api/users/" + String(model.userID)
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
        let map = ["user" : user]
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateTeamMember success", terminator: "")
            comp(true, "", model)
        }) { (op, error) in
            print("updateTeamMember failed", terminator: "")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }
}

