//
//  DataMnager + Invitation.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/29/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import SwiftyJSON

extension DataManager {
    
    func verifyCarPoolInvitation(phoneNum: String, comp: completion) {
        let url = baseURL + "/api/invites/verify"
        let map = ["phone_number": phoneNum]
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("verifyCarPoolInvitation success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("verifyCarPoolInvitation failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func invite(phoneNumbers: [String], carpoolID: Int, comp: completion) {
        let url = baseURL + "/api/invites"
        let invite = ["carpool_id": String(carpoolID), "phone_numbers": phoneNumbers]
        let map = ["invite": invite]
        print(map, terminator: "")
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("invite success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("invite failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func acceptInvite(invite: InvitationModel, comp: completion) {
        let url = baseURL + "/api/invites/\(invite.inviteID)/accept"
        let manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            print("acceptInvite success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("acceptInvite failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func declineInvite(invite: InvitationModel, comp: completion) {
        let url = baseURL + "/api/invites/\(invite.inviteID)/reject"
        let manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            print("declineInvite success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("declineInvite failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func getInvitations(comp: ObjectCompletion) {
        let url = baseURL + "/api/invites/"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getInvitations success", terminator: "")
            var json = JSON(obj)
            var invitations: [InvitationModel]!

            if let _invitations = json["invites"].array as [JSON]? {
                invitations = _invitations.map {
                    return InvitationModel(json: $0)
                }
            }

            comp(true, "", invitations)
        }) { (op, error) in
            print("getInvitations failed", terminator: "")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func getInvitationByCode(code: String, comp: ObjectCompletion) {
        let url = baseURL + "/api/invites/\(code)"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            var json = JSON(obj)
            let invitation = InvitationModel(json: json["invite"])
            comp(true, "", invitation)
        }) { (op, error) in
            print("getFirstInvitation failed", terminator: "")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func joinInvitersTeam(invite: InvitationModel, comp: completion) {
        let url = baseURL + "/api/invites/\(invite.inviteID)/add_to_team"
        let manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            print("joinInvitersTeam success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("joinInvitersTeam failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

}
