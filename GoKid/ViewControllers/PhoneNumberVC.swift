//
//  PhoneNumberVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 8/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class PhoneNumberVC: BaseVC, UITextFieldDelegate {

    @IBOutlet weak var phoneNumber: PaddingTextField!

    var parentVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForKeyBoardNotification()
        self.phoneNumber.keyboardType = .PhonePad
    }

    func afterSignIn() {
        (self.parentVC as! MainStackVC).refreshCurrentVC(false)
    }

    override func leftNavButtonTapped() {
        self.parentVC.dismissViewControllerAnimated(true, completion: nil)
    }

    override func rightNavButtonTapped() {
        if phoneNumber.text != "" {
            // checkPhone(phoneNumber.text)
            if userManager.userLoggedIn {
                savePhone(phoneNumber.text)
            } else {
                fbRegistrationWithPhone(phoneNumber.text)
            }
        } else {
            showAlert("Correction", messege: "Please enter a valid phone number", cancleTitle: "OK")
        }
    }

    private func fbRegistrationWithPhone(phone: String) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.fbSignin(phone) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.parentVC.dismissViewControllerAnimated(true, completion: self.afterSignIn)
            } else {
                self.showAlert("Failed to sign in with Facebook", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    private func savePhone(phone: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.updatePhoneNumber(phone) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.leftNavButtonTapped()
            } else {
                self.showAlert("Failed to Submit", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    private func checkPhone(phone: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.requestVerificationCode(phone) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.alertPhoneVerification(phone)
            } else {
                self.showAlert("Failed to Submit", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    private func alertPhoneVerification(phone: String) {
        if phone == "" { return }

        var msg = "We have sent a verification code to ###. Please check your phone."
        msg = msg.replace("###", phone)

        let confirmPrompt = UIAlertController(title: "Verify Your Phone", message: msg, preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "enter code"
        }

        confirmPrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        confirmPrompt.addAction(UIAlertAction(title: "Verify", style: .Default, handler: { (alert: UIAlertAction!) in
            if let textField = confirmPrompt.textFields?.first as? UITextField{
                self.verifyPhone(textField.text)
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
    }

    private func verifyPhone(verification: String) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.memberPhoneVerification(verification) { (success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")
                self.userManager.info.phoneNumber = self.phoneNumber.text
                self.userManager.saveUserInfo()

                InvitationModel.checkInvitations()
                
                self.parentVC.dismissViewControllerAnimated(true, completion: self.afterSignIn)
            } else {
                LoadingView.dismiss()
                self.showAlert("Verification Failed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    // MARK: TextField Delegate
    // --------------------------------------------------------------------------------------------

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.phoneNumber {
            self.rightNavButtonTapped()
            return false
        }

        return true
    }

}
