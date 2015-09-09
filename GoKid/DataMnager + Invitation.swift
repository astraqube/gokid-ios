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
    
    func acceptInvite(invite: InvitationModel, comp: completion) {
        var url = baseURL + "/api/invites/\(invite.inviteID)/accept"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("acceptInvite success")
            comp(true, "")
        }) { (op, error) in
            println("acceptInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func declineInvite(invite: InvitationModel, comp: completion) {
        var url = baseURL + "/api/invites/\(invite.inviteID)/reject"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("declineInvite success")
            comp(true, "")
        }) { (op, error) in
            println("declineInvite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func getInvitations(comp: ObjectCompletion) {
        var url = baseURL + "/api/invites/"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getInvitations success")
            var json = JSON(obj)
            var invitations: [InvitationModel]!

            if let _invitations = json["invites"].array as [JSON]? {
                invitations = _invitations.map {
                    return InvitationModel(json: $0)
                }
            }

            comp(true, "", invitations)
        }) { (op, error) in
            println("getInvitations failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func getInvitationByCode(code: String, comp: ObjectCompletion) {
        var url = baseURL + "/api/invites/\(code)"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            var json = JSON(obj)
            var invitation = InvitationModel(json: json["invite"])
            comp(true, "", invitation)
        }) { (op, error) in
            println("getFirstInvitation failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

}
