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

    var carpool: CarpoolModel!

    ///In case someone wants to hit Edit button from DetailMapVC, default: true
    var hideForwardNavigationButtons = true
    @IBOutlet weak var carpoolNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setStatusBarColorDark()
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.subtitleLabel?.text = carpool.descriptionString
        carpoolNameLabel.text = "\"\(carpool.name)\""
        rightButton.hidden = hideForwardNavigationButtons
        rightButton.enabled = !hideForwardNavigationButtons
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func chooseFromContactListButtonClick(sender: AnyObject) {
        var vc = vcWithID("ContactPickerVC") as! ContactPickerVC
        vc.carpool = self.carpool
        navigationController?.pushViewController(vc, animated: true)
    }
/* DEPRECATED
    @IBAction func InviteViaEmailButtomClick(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showCannotSendMailErrorAlert()
        }
    }
*/
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        var vc = vcWithID("CarpoolSucceedVC") as! CarpoolSucceedVC
        vc.carpool = self.carpool
        navigationController?.pushViewController(vc, animated: true)
    }
/* DEPRECATED
    // MARK: Send Mail
    // --------------------------------------------------------------------------------------------
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Let's carpool for \(carpool.name)")
        mailComposerVC.setMessageBody("Hey there, \n\nI made a carpool on GoKid: \(carpool.descriptionString). Can you guys join?\n Use this link to get the app itunes.apple.com/a1831jal029\n\n Love,\n\(userManager.info.firstName)", isHTML: false)
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
*/
}
