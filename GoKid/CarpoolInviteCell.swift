//
//  CarpoolInviteCell.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CarpoolInviteCell: UITableViewCell {

    weak var invitation: InvitationModel!

    @IBOutlet weak var inviteInfoLabel: UILabel!
    @IBOutlet weak var inviteTitleLabel: UILabel!

    var onAccept : ((invitation: InvitationModel)->())?
    var onDecline : ((invitation: InvitationModel)->())?

    func refreshContent() {
        inviteInfoLabel.text =  inviteInfoLabel.text?.replace("XXX", invitation.inviter.firstName)
        inviteTitleLabel.text = invitation.carpool.name
    }

    @IBAction func acceptButtonClick(sender: AnyObject) {
        self.onAccept?(invitation: self.invitation)
    }

    @IBAction func declineButtonClick(sender: AnyObject) {
        self.onDecline?(invitation: self.invitation)
    }

}
