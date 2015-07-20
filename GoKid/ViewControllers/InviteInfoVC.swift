//
//  InviteInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteInfoVC: BaseFormVC {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // require user session
        self.postNotification("requestForUserToken")
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: "phone", rowType: XLFormRowDescriptorTypePhone, title: "Phone Number")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        section.addFormRow(row)

        section.footerTitle = "Enter the phone number in which you received the invitation"

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

        LoadingView.showWithMaskType(.Black)
        dataManager.verifyCarPoolInvitation(formData["phone"] as! String) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                var vc = vcWithID("PhoneVerifyVC")
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Can't find that Invitation", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
