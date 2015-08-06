//
//  InviteInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteInfoVC: BaseFormVC {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.requireSignup()
        self.requirePhoneNumber()
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: "code", rowType: XLFormRowDescriptorTypeText, title: "Invitation Code")
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["textField.font"] = valueFont
        row.cellConfig["textField.tintColor"] = labelColor
        row.required = true
        section.addFormRow(row)

        section.footerTitle = "Enter the invitation code you received"

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

    func requireSignup() {
        // require user session
        if self.userManager.userLoggedIn == false {
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainController = appDelegate.window!.rootViewController as! MainStackVC
            mainController.popUpSignUpView()
        }
    }

    func requirePhoneNumber() {
        // require user session and phone number
        if self.userManager.userLoggedIn == true && self.userManager.info.phoneNumber == "" {
            self.postNotification("requestForPhoneNumber")
        }
    }

    private func proceed() {
        let formData = self.form.formValues()
        var verificationCode = formData["code"] as? String

        LoadingView.showWithMaskType(.Black)
        dataManager.getInvitationByCode(verificationCode!) { (success, errorStr, invitation) in
            LoadingView.dismiss()
            if success {
                var vc = vcWithID("InviteConfirmVC") as! InviteConfirmVC
                vc.invitation = invitation as! InvitationModel
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Invitation Problem", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
