//
//  DataMnager + Invitation.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/29/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension DataManager {
    
    func verifyCarPoolInvitation(phoneNum: String, comp: completion) {
        var url = baseURL + "/api/invites/verify"
        var map = ["phone_number": phoneNum]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("verifyCarPoolInvitation success")
            var json = JSON(obj)
            println(json)
            comp(true, "")
        }) { (op, error) in
            println("verifyCarPoolInvitation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func inviteSignupUser(phoneNum: String, code: String, form: SignupForm, comp: completion) {
        var url = baseURL + "/api/invite/verify"
        var map = [
            "phone_number": phoneNum,
            "code": code,
            "user": "ass"
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("inviteSignupUser success")
            var json = JSON(obj)
            println(json)
            
            comp(true, "")
        }) { (op, error) in
            println("inviteSignupUser failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func invite(phoneNumbers: [String], carpoolID: Int, comp: completion) {
        var url = baseURL + "/api/invites"
        var invite = ["carpool_id": String(carpoolID), "phone_numbers": phoneNumbers]
        var map = ["invite": invite]
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("invite success")
            comp(true, "")
        }) { (op, error) in
            println("invite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func acceptInvite(comp: completion) {
        var url = baseURL + "/api/invite/accept"
        var map = ["invite_id", ""]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("acceptInvite success")
            var json = JSON(obj)
            comp(true, "")
        }) { (op, error) in
            println("acceptInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func declineInvite(comp: completion) {
        var url = baseURL + "/api/invite/reject"
        var map = ["invite_id", ""]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("declineInvite success")
            var json = JSON(obj)
            comp(true, "")
        }) { (op, error) in
            println("declineInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}