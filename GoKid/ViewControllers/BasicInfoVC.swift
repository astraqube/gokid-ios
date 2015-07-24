//
//  BasicInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class BasicInfoVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var carpoolTitleTextField: PaddingTextField!
    @IBOutlet weak var kidsNameTextField: PaddingTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userManager.currentCarpoolModel = CarpoolModel()

        self.carpoolTitleTextField.delegate = self
        self.kidsNameTextField.delegate = self

        self.rightButton.enabled = self.canProceed()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.carpoolTitleTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func rightNavButtonTapped() {
        if self.canProceed() {
            userManager.currentCarpoolModel.kidName = kidsNameTextField.text!
            userManager.currentCarpoolModel.name = carpoolTitleTextField.text!
            var vc = vcWithID("TimeAndDateFormVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func carpoolTitleChanged(sender: AnyObject) {
        self.rightButton.enabled = self.canProceed()
    }
    
    @IBAction func kidsNameChanged(sender: AnyObject) {
        self.rightButton.enabled = self.canProceed()
    }
    
    // MARK: Helper Methos
    // --------------------------------------------------------------------------------------------
    
    func canProceed() -> Bool {
        var s1 = carpoolTitleTextField.text
        var s2 = kidsNameTextField.text
        return count(s1) > 0 && count(s2) > 0
    }

    // MARK: TextField Delegate
    // --------------------------------------------------------------------------------------------

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.carpoolTitleTextField {
            self.kidsNameTextField.becomeFirstResponder()
            return false
        }

        if textField == self.kidsNameTextField {
            self.kidsNameTextField.resignFirstResponder()
            self.rightNavButtonTapped()
            return false
        }

        return true
    }

}
