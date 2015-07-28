//
//  Phone#VC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//
/* DEPRECATED
import UIKit

class Phone_VC: BaseVC {
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    var memberProfileVC: MemberProfileVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
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
        if phoneNumberTextField.text != "" {
            requestVerificationCode(phoneNumberTextField.text)
        } else {
            showAlert("Action Required", messege: "Please fill you phone number to proceed", cancleTitle: "OK")
        }
    }
    
    func requestVerificationCode(phoneNum: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.requestVerificationCode(phoneNum) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.procceedToNextVC()
            } else {
                self.showAlert("Fail to Request Verification", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func procceedToNextVC() {
        var phoneVerifyVC = vcWithID("PhoneVerifyVC") as! PhoneVerifyVC
        phoneVerifyVC.memberProfileVC = memberProfileVC
        phoneVerifyVC.phoneNumberString = phoneNumberTextField.text
        self.navigationController?.pushViewController(phoneVerifyVC, animated: true)
    }
}
*/
