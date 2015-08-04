//
//  PhoneVerifyVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//
/* DEPRECATED
import UIKit

class PhoneVerifyVC: BaseFormVC {
    
    var memberProfileVC: MemberProfileVC?
    var phoneNumberString = ""

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: "verification", rowType: XLFormRowDescriptorTypeText, title: "Verification Code")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.tintColor"] = colorLabel
        row.required = true
        section.addFormRow(row)

        let msg = "We have sent a verification code to ###. Please check your phone."
        section.footerTitle = msg.replace("###", self.phoneNumberString)

        form.addFormSection(section)
        form.assignFirstResponderOnShow = true

        self.form = form
        self.form.delegate = self
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)
        
        self.toggleRightNavButtonState()
    }
    
    override func rightNavButtonTapped() {
        let validationErrors: Array<NSError> = self.formValidationErrors() as! Array<NSError>

        if validationErrors.count > 0 {
            self.showFormValidationError(validationErrors.first)
            return
        }

        self.tableView.endEditing(true)

        self.proceed()
    }

    private func proceed() {
        let formData = self.form.formValues()
        let verification = formData["verification"] as! String

        LoadingView.showWithMaskType(.Black)
        dataManager.memberPhoneVerification(verification) {(success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")

                self.dataManager.getFirstInvitation() { (success, errorStr, invitation) -> () in
                    if success {
                        LoadingView.dismiss()
                        var vc = vcWithID("InviteConfirmVC") as! InviteConfirmVC
                        vc.invitation = invitation as! InvitationModel
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        LoadingView.dismiss()
                        self.showAlert("There's a problem", messege: errorStr, cancleTitle: "OK")
                    }
                }

            } else {
                LoadingView.dismiss()
                self.showAlert("Verification Failed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
*/
