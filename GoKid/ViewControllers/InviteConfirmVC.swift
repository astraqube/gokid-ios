//
//  InviteConfirmVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteConfirmVC: BaseVC {

    var invitation: InvitationModel!

    @IBOutlet weak var inviteLabel: UILabel!
    @IBOutlet weak var inviteImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteLabel.text = inviteLabel.text?.replace("xPoolNamex", invitation.carpool.name)
        inviteLabel.text = inviteLabel.text?.replace("xNamex", invitation.inviter.firstName)
        inviteLabel.text = inviteLabel.text?.replace("xKidx", invitation.rider.firstName)
        ImageManager.sharedInstance.setImageToView(inviteImage, urlStr: invitation.inviter.thumURL)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setStatusBarColorDark()
    }

    override func leftNavButtonTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func acceptButtonClick(sender: AnyObject) {
        LoadingView.showWithMaskType(.Black)
        invitation.accept() { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.moveToInviteRelationVC()
            } else {
                self.showAlert("Fail to accept carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    @IBAction func declineButtonClick(sender: AnyObject) {
        LoadingView.showWithMaskType(.Black)
        invitation.decline() { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.moveToTeamAccountVC()
            } else {
                self.showAlert("Fail to accept carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    @IBAction func inviteeListButtonClick(sender: AnyObject) {
        var vc = vcWithID("InviteesVC") as! InviteesVC
        vc.carpool = self.invitation.carpool
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func moveToInviteRelationVC() {
        onMainThread() {
            var vc = vcWithID("InviteRelationshipVC") as! InviteRelationshipVC
            vc.invitation = self.invitation
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func moveToTeamAccountVC() {
        onMainThread() {
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainController = appDelegate.window!.rootViewController as! MainStackVC
            mainController.determineStateForViews()
        }
    }
}
