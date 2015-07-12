//
//  InviteRelationshipVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteRelationshipVC: BaseVC {

    @IBOutlet weak var connectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        connectionLabel.text = connectionLabel.text?.replace("XXX", userManager.inviteKidName)
    }
    
    @IBAction func kidsFriendClick(sender: AnyObject) {
        moveToYourKidVC()
    }
    
    @IBAction func mommyClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC(RoleTypeMommy)
    }
    
    @IBAction func daddyClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC(RoleTypeDaddy)
    }
    
    @IBAction func sitterClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC(RoleTypeCareTaker)
    }
    
    @IBAction func otherClick(sender: AnyObject) {
        moveToYourKidVC()
    }
    
    func moveToYourKidVC() {
        var vc = vcWithID("YourKidVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setRoleAndMoveToVolunteerVC(role: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateUserRole(role) { (success, errStr) in
            LoadingView.dismiss()
            if success {
                onMainThread() {
                    var vc = vcWithID("VolunteerVC")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showAlert("Fail to update role", messege: errStr, cancleTitle: "OK")
            }
        }
    }
}
