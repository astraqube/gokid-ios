//
//  MemberProfileVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MemberProfileVC: UITableViewController {
    
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var um = UserManager.sharedInstance
        profileImageView.image = um.userProfileImage
        nameLabel.text = um.userName
        setupNavBar()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your profile")
        setNavBarRightButtonTitle("Save", action: "saveButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func saveButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhoneVerification" {
            var des = segue.destinationViewController as! Phone_VC
            des.memberProfileVC = self
        }
    }
}
