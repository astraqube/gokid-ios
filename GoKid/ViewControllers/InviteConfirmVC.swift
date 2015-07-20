//
//  InviteConfirmVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteConfirmVC: BaseVC {
    
    @IBOutlet weak var inviteLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var kidNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        inviteLabel.text = inviteLabel.text?.replace("xPoolNamex", userManager.currentCarpoolModel.name)
        inviteLabel.text = inviteLabel.text?.replace("xNamex", userManager.inviterName)
        kidNameLabel.text = kidNameLabel.text?.replace("xxx", userManager.inviteKidName)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func acceptButtonClick(sender: AnyObject) {
        LoadingView.showWithMaskType(.Black)
        dataManager.acceptInvite(userManager.inviteID) { (success, errorStr) in
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
        dataManager.declineInvite(userManager.inviteID) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.moveToTeamAccountVC()
            } else {
                self.showAlert("Fail to accept carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    @IBAction func viewInviteeListButtonClick(sender: AnyObject) {
        var vc = vcWithID("InviteeListVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveToInviteRelationVC() {
        onMainThread() {
            var vc = vcWithID("InviteRelationshipVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func moveToTeamAccountVC() {
        onMainThread() {
            var calenderVC = vcWithID("CalenderVC")
            var teamAccountVC = vcWithID("TeamAccountVC")
            var vcs = [calenderVC, teamAccountVC]
            self.navigationController?.setViewControllers(vcs, animated: true)
        }
    }
}
