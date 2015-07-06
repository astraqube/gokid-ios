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
            comp(true, "")
        }) { (op, error) in
            println("verifyCarPoolInvitation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func inviteSignupUser(phoneNum: String, code: String, form: SignupForm, comp: completion) {
        var url = baseURL + "/api/invites/signup"
        var user = [
            "email": form.email,
            "password": form.password,
            "password_confirmation": form.password,
            "phone_number": form.phoneNum,
            "last_name": form.lastName,
            "first_name": form.firstName,
        ]
        var map = [
            "phone_number": phoneNum,
            "verification_code": code,
            "user": user
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("inviteSignupUser success")
            var json = JSON(obj)
            println(json)
            self.userManager.currentCarpoolModel = CarpoolModel(json: json)
            self.userManager.inviteID = json["invite"]["id"].intValue
            self.userManager.setWithJsonReponse(json)
            self.userManager.userLoggedIn = true
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
    
    func acceptInvite(inviteID: Int, comp: completion) {
        var url = baseURL + "/api/invites/" + String(inviteID) + "/accept"
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
    
    func declineInvite(inviteID: Int, comp: completion) {
        var url = baseURL + "/api/invites/" + String(inviteID) + "/reject"
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