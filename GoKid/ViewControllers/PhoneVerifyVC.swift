//
//  PhoneVerifyVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

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

        row = XLFormRowDescriptor(tag: "verification", rowType: XLFormRowDescriptorTypeNumber, title: "Verification Code")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        section.addFormRow(row)

        let msg = "We have sent a verification code to ###. Please check your phone."
        section.footerTitle = msg.replace("###", self.phoneNumberString)

        form.addFormSection(section)

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
        let verification = formData["verification"] as! Int

        LoadingView.showWithMaskType(.Black)
        dataManager.memberPhoneVerification(verification.description) {(success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")

                if let vc = self.memberProfileVC {
                    vc.phoneNumberLabel.text = self.phoneNumberString
                    self.navigationController?.popToViewController(vc, animated: true)
                } else {
                    var vc = vcWithID("InviteConfirmVC")
                    self.navigationController?.pushViewController(vc, animated: true)
                }

            } else {
                LoadingView.dismiss()
                self.showAlert("Verification Failed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
