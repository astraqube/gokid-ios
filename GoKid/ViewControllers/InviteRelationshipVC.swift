//
//  InviteRelationshipVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteRelationshipVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func kidsFriendClick(sender: AnyObject) {
        var vc = vcWithID("YourKidVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mommyClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC("mommy")
    }
    
    @IBAction func daddyClick(sender: AnyObject) {
        setRoleAndMoveToVolunteerVC("daddy")
    }
    
    @IBAction func sitterClick(sender: AnyObject) {
        
    }
    
    @IBAction func otherClick(sender: AnyObject) {
        
    }
    
    func setRoleAndMoveToVolunteerVC(role: String) {
        dataManager.updateUserRole(role) { (success, errStr) in
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
