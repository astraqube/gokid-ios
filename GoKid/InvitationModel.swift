//
//  InvitationModel.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/29/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InvitationModel: NSObject {
    var inviteID: Int!
    var inviter: RiderModel!
    var carpool: CarpoolModel!
    var rider: RiderModel!

    override init() {
        super.init()
    }

    init(json: JSON) {
        inviteID = json["id"].intValue
        inviter = RiderModel(json: json["inviter"])
        carpool = CarpoolModel(json: json["carpool"])
        rider = RiderModel(json: json["carpool"]["riders"][0])
    }
}
