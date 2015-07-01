//
//  DataMnager + Invitation.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/29/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension DataManager {
    
    func acceptInvite(comp: completion) {
        var url = baseURL + "/api/invites/:invite_id/accept"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("acceptInvite success")
            var json = JSON(obj)
            comp(true, "")
        }) { (op, error) in
            println("acceptInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func declineInvite(comp: completion) {
        var url = baseURL + "POST /api/invites/:invite_id/reject"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("declineInvite success")
            var json = JSON(obj)
            comp(true, "")
        }) { (op, error) in
            println("declineInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}