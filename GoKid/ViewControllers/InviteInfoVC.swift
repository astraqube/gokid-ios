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
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.tintColor"] = colorLabel
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

    func requireSignup() {
        // require user session
        if self.userManager.userLoggedIn == false {
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainController = appDelegate.window!.rootViewController as! MainStackVC
            mainController.popUpSignUpView()
        }
    }

    private func proceed() {
        let formData = self.form.formValues()
        var phoneNumber = formData["phone"] as? String

        LoadingView.showWithMaskType(.Black)
        dataManager.requestVerificationCode(phoneNumber!) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                var vc = vcWithID("PhoneVerifyVC") as! PhoneVerifyVC
                vc.phoneNumberString = phoneNumber!
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Can't find that Invitation", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
