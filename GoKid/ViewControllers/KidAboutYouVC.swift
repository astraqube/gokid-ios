//
//  KidAboutYouVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import AddressBookUI

class KidAboutYouVC: BaseVC, ABPeoplePickerNavigationControllerDelegate {

    @IBOutlet weak var phoneNumbertextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("About You")
        setNavBarRightButtonTitle("Next", action: "nextButtonClicked")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func nextButtonClicked() {
        var memberProfileVC = vcWithID("MemberProfileVC")
        self.navigationController?.pushViewController(memberProfileVC, animated: true)
    }
    
    @IBAction func chooseFromContactButtonClicked(sender: AnyObject) {
        var picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: ABPeoplePickerNavigationControllerDelegate
    // --------------------------------------------------------------------------------------------
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
        let phoneNumbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            let number = ABMultiValueCopyValueAtIndex(phoneNumbers, 0).takeRetainedValue() as! String
            phoneNumbertextField.text = number
        } else {
            println("No Phone number")
        }
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
        return false;
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        peoplePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}
