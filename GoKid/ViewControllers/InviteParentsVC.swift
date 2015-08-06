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
    ///In case someone wants to hit Edit button from DetailMapVC, default: true
    var hideForwardNavigationButtons = true
    @IBOutlet weak var carpoolNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNacBar()
        refreshUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupNacBar() {
        self.subtitleLabel?.text = userManager.currentCarpoolDescription()
    }
    
    func refreshUI() {
        carpoolNameLabel.text = "\"" + userManager.currentCarpoolModel.name + "\""
        rightButton.hidden = hideForwardNavigationButtons
        rightButton.enabled = !hideForwardNavigationButtons
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func chooseFromContactListButtonClick(sender: AnyObject) {
        showContactPicker()
    }
    
    @IBAction func InviteViaEmailButtomClick(sender: AnyObject) {
        showMailVC()
    }

    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        var vc = vcWithID("CarpoolSucceedVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Choose From Contact
    // --------------------------------------------------------------------------------------------
    
    func showContactPicker() {
        var vc = vcWithID("ContactPickerVC") as! ContactPickerVC
        vc.carpool = userManager.currentCarpoolModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Send Mail
    // --------------------------------------------------------------------------------------------
    
    func showMailVC() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showCannotSendMailErrorAlert()
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
    
    func showCannotSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
        case MFMailComposeResultSent.value:
            self.showAlert("Success", messege: "Your invitation email was sent", cancleTitle: "OK")
        case MFMailComposeResultSaved.value:
            self.showAlert("Saved", messege: "Your invitation email was saved", cancleTitle: "OK")
        case MFMailComposeResultFailed.value:
            self.showAlert("Error", messege: "Cannot sent email, please check your network connection", cancleTitle: "OK")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
