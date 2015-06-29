//
//  PhoneVerifyVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class PhoneVerifyVC: BaseVC {
    
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var codeTextField: PaddingTextField!
    var memberProfileVC: MemberProfileVC?
    var phoneNumberString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTextField()
    }
    
    func setupNavBar() {
        setNavBarTitle("Phone Verify")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Done", action: "doneButtonClick")
    }
    
    func setupTextField() {
        var str = infoTextLabel.text
        infoTextLabel.text = str?.replace("#########", phoneNumberString)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func doneButtonClick() {
        if codeTextField.text != "" {
            verifyCode(codeTextField.text)
        } else {
            showAlert("Action required", messege: "Please fill you verification code", cancleTitle: "OK")
        }
    }
    
    func verifyCode(code: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.VerifyCode(code) {(success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")
                self.handleVerificationSuccess()
            } else {
                LoadingView.dismiss()
                self.showAlert("Fail", messege: "Verification Code Wrong", cancleTitle: "OK")
            }
        }
    }
    
    func handleVerificationSuccess() {
        if let vc = memberProfileVC {
            vc.phoneNumberLabel.text = phoneNumberString
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
}

