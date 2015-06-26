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

    @IBOutlet weak var carpoolNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
    }
    
    func refreshUI() {
        carpoolNameLabel.text = userManager.currentCarpoolModel.name
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func chooseFromContactListButtonClick(sender: AnyObject) {
        showContactPicker()
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
    
    func showContactPicker() {
        var vc = vcWithID("ContactPickerVC")
        navigationController?.pushViewController(vc, animated: true)
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
        mailComposerVC.setSubject("Let's carpool for Soccer Practice")
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
