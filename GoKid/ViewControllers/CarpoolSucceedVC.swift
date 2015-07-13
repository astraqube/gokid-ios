//
//  CarpoolSucceedVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CarpoolSucceedVC: BaseVC, UIAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        showAlertView()
    }
    
    func setupNavBar() {
        self.subtitleLabel?.text = userManager.currentCarpoolDescription()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        var vc = vcWithID("CalendarVC")
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func viewCalendarButtonClick(sender: AnyObject) {
        rightNavButtonTapped()
    }
    
    @IBAction func addTeamMemberButtonClick(sender: AnyObject) {
        var vc = vcWithID("TeamAccountVC")
        navigationController?.setViewControllers([vc], animated: true)
    }
    
    // MARK: Register Notification For App
    // --------------------------------------------------------------------------------------------
    
    func registerForPushNotification() {
        var setting = UIUserNotificationSettings(forTypes: .Badge | .Alert | .Sound, categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showAlertView() {
        var alertView = UIAlertView(title: "", message: "Do you want to know when your kids have safely arrived at their destinations?", delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            registerForPushNotification()
        }
    }
}
