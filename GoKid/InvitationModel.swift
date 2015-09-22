//
//  InvitationModel.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/29/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import SwiftyJSON

class InvitationModel: NSObject {
    var inviteID: Int!
    var inviter: RiderModel!
    var carpool: CarpoolModel!
    var rider: RiderModel!
    var status: String!
    var phoneNum: String!

    override init() {
        super.init()
    }

    init(json: JSON) {
        inviteID = json["id"].intValue
        inviter = RiderModel(json: json["inviter"])
        carpool = CarpoolModel(json: json["carpool"])
        rider = RiderModel(json: json["carpool"]["riders"][0])
        status = json["status"].stringValue
        phoneNum = json["phone_number"].stringValue
    }

    class var InvitationCount: Int? {
        set {
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(newValue!, forKey: kGKInvitationsKey)
            prefs.synchronize()

            let app = UIApplication.sharedApplication()
            app.applicationIconBadgeNumber = newValue!
        
            app.postNotification("invitationsUpdated")
        }
        get {
            let prefs = NSUserDefaults.standardUserDefaults()
            let badge = prefs.valueForKey(kGKInvitationsKey) as? Int
            return badge
        }
    }

    class func checkInvitations() {
        DataManager.sharedInstance.getInvitations() { (success, error, invitations) in
            if success {
                UserManager.sharedInstance.invitations = invitations as! [InvitationModel]
                InvitationModel.InvitationCount = UserManager.sharedInstance.invitations.count
            }
        }
    }

    func accept(comp: completion) {
        DataManager.sharedInstance.acceptInvite(self) { (success, error) in
            if success {
                if let index = UserManager.sharedInstance.invitations.indexOf(self) {
                    UserManager.sharedInstance.invitations.removeAtIndex(index)
                    InvitationModel.InvitationCount = UserManager.sharedInstance.invitations.count
                }
            }
            comp(success, error)
        }
    }

    func decline(comp: completion) {
        DataManager.sharedInstance.declineInvite(self) { (success, error) in
            if success {
                if let index = UserManager.sharedInstance.invitations.indexOf(self) {
                    UserManager.sharedInstance.invitations.removeAtIndex(index)
                    InvitationModel.InvitationCount = UserManager.sharedInstance.invitations.count
                }
            }
            comp(success, error)
        }
    }

    func joinTeam(comp: completion) {
        DataManager.sharedInstance.joinInvitersTeam(self, comp: comp)
    }
}
