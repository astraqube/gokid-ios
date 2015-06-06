//
//  InviteParentsVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MessageUI
import AddressBookUI

class InviteParentsVC: BaseVC, MFMailComposeViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func chooseFromContactListButtonClick(sender: AnyObject) {
        showPeoplePickerNavigationController()
    }
    
    @IBAction func InviteViaEmailButtomClick(sender: AnyObject) {
        showMailVC()
    }

    @IBAction func doItLaterButtonClicker(sender: AnyObject) {
        var vc = vcWithID("CarpoolSucceedVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Choose From Contact
    // --------------------------------------------------------------------------------------------
    
    func showPeoplePickerNavigationController() {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
        let phoneNumbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            let number = ABMultiValueCopyValueAtIndex(phoneNumbers, 0).takeRetainedValue() as! String
            // phoneNumbertextField.text = number
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
    
    // MARK: Send Mail
    // --------------------------------------------------------------------------------------------
    
    func showMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Let's carpool for Socer Practice")
        mailComposerVC.setMessageBody("Hey there, \n\nI made a carpool on go kids For Tom's Soccer Practice. Can you guys join?\n Use this link to get the app itunes.apple.com/a1831jal029\n\n Love,\nLiz", isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
