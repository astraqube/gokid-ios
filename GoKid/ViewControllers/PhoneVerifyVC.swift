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
    var signupForm: SignupForm?
    var phoneNumberString = ""
    var fromCarpoolInvite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTextField()
    }
    
    func setupNavBar() {
        setNavBarTitle("Phone Verify")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "doneButtonClick")
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
    
    // MARK: Network Flow
    // --------------------------------------------------------------------------------------------
    
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
        onMainThread() {
            if self.fromCarpoolInvite {
                self.verificatoinSuccessFromCarpoolInvite()
            } else {
                self.verificationSuccessFromMemberProfile()
            }
        }
    }
    
    func verificatoinSuccessFromCarpoolInvite() {
        var vc = vcWithID("InviteConfirmVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func verificationSuccessFromMemberProfile() {
        if let vc = memberProfileVC {
            vc.phoneNumberLabel.text = phoneNumberString
            navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    // MARK: Carpool Invitation Nextwork flow
    // --------------------------------------------------------------------------------------------
    
    func verifyCodeFromInvite(code: String) {
        dataManager.inviteSignupUser(phoneNumberString, code: code, form: signupForm!) { (success, errorStr) in
            if success {
                
            } else {
                self.showAlert("Fail to proceed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
}

