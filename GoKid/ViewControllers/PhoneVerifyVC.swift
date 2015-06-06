//
//  PhoneVerifyVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class PhoneVerifyVC: BaseVC {
    
    var memberProfileVC: MemberProfileVC?
    var phoneNumberString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    func setupNavBar() {
        setNavBarTitle("Phone Verify")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Done", action: "doneButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneButtonClick() {
        if let vc = memberProfileVC {
            vc.phoneNumberLabel.text = phoneNumberString
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
}
