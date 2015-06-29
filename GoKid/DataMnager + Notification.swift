//
//  DataManager + Notification.swift
//  
//
//  Created by Bingwen Fu on 6/27/15.
//
//

import UIKit

extension DataManager {
    
    // MARK: Network request for notifications
    // --------------------------------------------------------------------------------------------
    
    func updateNotificationToken(token: String, comp: completion) {
        var url = baseURL + "/api_ios_device_token"
        var map = ["device_token": token]
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
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
