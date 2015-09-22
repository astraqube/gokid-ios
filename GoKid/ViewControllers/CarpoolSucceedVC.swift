//
//  CarpoolSucceedVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CarpoolSucceedVC: BaseVC {

    var carpool: CarpoolModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        promptForPushNotification()
    }
    
    func setupNavBar() {
        self.subtitleLabel?.text = carpool.descriptionString
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainController = appDelegate.window!.rootViewController as! MainStackVC
        mainController.setSignedInView("CalendarVC")
    }
    
    @IBAction func addTeamMemberButtonClick(sender: AnyObject) {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainController = appDelegate.window!.rootViewController as! MainStackVC
        mainController.setSignedInView("TeamAccountVC")
    }
    
    // MARK: Register Notification For App
    // --------------------------------------------------------------------------------------------
    
    func promptForPushNotification() {
        let app = UIApplication.sharedApplication()
        let notifications = app.currentUserNotificationSettings()

        if notifications!.types == .None {
            let confirmPrompt = UIAlertController(title: "", message: "Do you want to know when your kids have safely arrived at their destinations?", preferredStyle: .Alert)

            confirmPrompt.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))

            confirmPrompt.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alert: UIAlertAction) in
                let setting = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil);
                app.registerUserNotificationSettings(setting)
            }))

            presentViewController(confirmPrompt, animated: true, completion: nil)
        }
    }

}
