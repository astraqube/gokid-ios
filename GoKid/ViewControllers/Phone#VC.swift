//
//  Phone#VC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class Phone_VC: BaseVC {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var memberProfileVC: MemberProfileVC?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupNavBar() {
        setNavBarTitle("Phone#")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var phoneVerifyVC = vcWithID("PhoneVerifyVC") as! PhoneVerifyVC
        phoneVerifyVC.memberProfileVC = memberProfileVC
        phoneVerifyVC.phoneNumberString = phoneNumberTextField.text
        self.navigationController?.pushViewController(phoneVerifyVC, animated: true)
    }
}
