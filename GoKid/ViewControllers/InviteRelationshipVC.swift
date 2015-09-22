//
//  InviteRelationshipVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteRelationshipVC: BaseVC {

    var invitation: InvitationModel!

    @IBOutlet weak var connectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setStatusBarColorDark()
        connectionLabel.text = connectionLabel.text?.replace("XXX", invitation.rider.firstName)
    }
    
    @IBAction func kidsFriendClick(sender: AnyObject) {
        moveToYourKidVC()
    }
    
    @IBAction func parentClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC(RoleTypeParent)
    }
    
    @IBAction func sitterClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC(RoleTypeCareTaker)
    }
    
    @IBAction func otherClick(sender: AnyObject) {
        moveToYourKidVC()
    }
    
    func moveToYourKidVC() {
        let vc = vcWithID("YourKidVC") as! YourKidVC
        vc.invitation = self.invitation
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setRoleAndMoveToVolunteerVC(role: String) {
        LoadingView.showWithMaskType(.Black)
        invitation.joinTeam { (success, error) in
            LoadingView.dismiss()
            if success {
                self.dataManager.updateUserRole(role) { (success, errStr) in
                    if success {
                        onMainThread() {
                            let vc = vcWithID("VolunteerVC") as! VolunteerVC
                            vc.carpool = self.invitation.carpool
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        self.showAlert("Failed to update role", messege: errStr, cancleTitle: "OK")
                    }
                }
            }
        }
    }
}
