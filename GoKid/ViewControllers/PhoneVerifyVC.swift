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
        if fromCarpoolInvite {
            inviteVerifyCode(code)
        } else {
            memberPhoneVerify(code)
        }
    }
    
    func memberPhoneVerify(code: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.memberPhoneVerification(code) {(success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")
                self.handleMemberPhoneVerificationSuccess()
            } else {
                LoadingView.dismiss()
                self.showAlert("Fail to verify code", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func handleMemberPhoneVerificationSuccess() {
        onMainThread() {
            if let vc = self.memberProfileVC {
                vc.phoneNumberLabel.text = self.phoneNumberString
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: Carpool Invitation Nextwork flow
    // --------------------------------------------------------------------------------------------
   
    func inviteVerifyCode(code: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.inviteSignupUser(phoneNumberString, code: code, form: signupForm!) { (success, errStr) in
            LoadingView.dismiss()
            if success {
                self.handleVerificatoinSuccessFromCarpoolInvite()
            } else {
                self.showAlert("Fail to verify code", messege: errStr, cancleTitle: "OK")
            }
        }
    }
    
    func handleVerificatoinSuccessFromCarpoolInvite() {
        onMainThread() {
            var vc = vcWithID("InviteConfirmVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

