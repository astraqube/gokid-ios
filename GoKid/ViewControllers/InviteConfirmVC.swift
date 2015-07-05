//
//  InviteConfirmVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteConfirmVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("You're invited")
        setNavBarLeftButtonTitle("Later", action: "laterButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func laterButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func acceptButtonClick(sender: AnyObject) {
        LoadingView.showWithMaskType(.Black)
        dataManager.acceptInvite { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                
            } else {
                
            }
        }
    }
    
    @IBAction func declineButtonClick(sender: AnyObject) {
        LoadingView.showWithMaskType(.Black)
        dataManager.declineInvite { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                
            } else {
                
            }
        }
    }
    
    @IBAction func viewInviteeListButtonClick(sender: AnyObject) {
        
    }
    
}
