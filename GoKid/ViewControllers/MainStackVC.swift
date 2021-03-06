//
//  MainStackVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MainStackVC: IIViewDeckController {

    var rootVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerForNotification("requestForUserToken", action: "popUpSignInView")
        self.registerForNotification("gotInvitedNotify", action: "notifyInvitationView")
        self.registerForNotification("gotInvited", action: "presentInvitationView")
        self.registerForNotification("requestForPhoneNumber", action: "popUpPhoneNumberView")
        self.registerForNotification("gotInviteeAcceptance", action: "notifyInviteeAcceptance")

        self.determineStateForViews()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // pickup a dropoff
        let prefs = NSUserDefaults.standardUserDefaults()

        if prefs.valueForKey("gotInvited") != nil {
            self.presentInvitationView()
        }

        if prefs.valueForKey("viewInvitees") != nil {
            self.notifyInviteeAcceptance()
        }
    }

    func determineStateForViews() {
        let userManager = UserManager.sharedInstance

        if userManager.userLoggedIn {
            self.setSignedInView()
        } else if userManager.useFBLogIn {
            self.setSetSignedInFBView()
        } else {
            self.setWelcomeView()
        }
    }

    func registerDeviceToken() {
        // pickup for deviceToken
        let prefs = NSUserDefaults.standardUserDefaults()
        if let token = prefs.valueForKey("deviceToken") as? String {
            if UserManager.sharedInstance.userLoggedIn {
                DataManager.sharedInstance.updateNotificationToken(token) { (success, errorStr) in
                    // do nothing here for now
                }
            }
        }
    }

    func setSignedInView() {
        self.setSignedInView("CalendarVC")
    }

    func setSignedInView(mainVCName: String) {
        let menuVC = vcWithID("MenuVC") as! MenuVC
        self.leftController = menuVC
        self.leftSize = 52

        self.rootVC = vcWithID(mainVCName)
        self.centerController = UINavigationController(rootViewController: self.rootVC)

        self.registerDeviceToken()
        self.presentInvitationView()
    }

    func setWelcomeView() {
        self.rootVC = OnboardVC()
        self.centerController = UINavigationController(rootViewController: self.rootVC)
    }

    func setSetSignedInFBView() {
        DataManager.sharedInstance.fbSignin() { (success, errorStr) in
            if success {
                self.setSignedInView()
            } else {
                println(errorStr)
                self.setWelcomeView()
            }
        }
    }

    func popUpSignInView() {
        var signInVC = vcWithID("SignInVC") as! SignInVC
        signInVC.parentVC = self
        signInVC.modalTransitionStyle = .CrossDissolve
        signInVC.modalPresentationStyle = .OverCurrentContext
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true) {
                self.presentViewController(signInVC, animated: true, completion: nil)
            }
        } else {
            self.presentViewController(signInVC, animated: true, completion: nil)
        }
    }

    func popUpSignUpView() {
        var signUpVC = vcWithID("SignUpVC") as! SignUpVC
        signUpVC.parentVC = self
        signUpVC.modalTransitionStyle = .CrossDissolve
        signUpVC.modalPresentationStyle = .OverCurrentContext
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true) {
                self.presentViewController(signUpVC, animated: true, completion: nil)
            }
        } else {
            self.presentViewController(signUpVC, animated: true, completion: nil)
        }
    }

    func popUpPhoneNumberView() {
        let userManager = UserManager.sharedInstance
        if userManager.info.phoneNumber == "" {
            var phoneNumberVC = vcWithID("PhoneNumberVC") as! PhoneNumberVC
            phoneNumberVC.parentVC = self
            phoneNumberVC.modalTransitionStyle = .CrossDissolve
            phoneNumberVC.modalPresentationStyle = .OverCurrentContext
            if self.presentedViewController != nil {
                self.dismissViewControllerAnimated(true) {
                    self.presentViewController(phoneNumberVC, animated: true, completion: nil)
                }
            } else {
                self.presentViewController(phoneNumberVC, animated: true, completion: nil)
            }
        }
    }

    func notifyInvitationView() {
        var alertView = UIAlertController(title: "Incoming", message: "You have just received a new Carpool Invitation.", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Open It", style: .Default, handler: { (action: UIAlertAction!) in
            self.presentInvitationView()
        }))
        alertView.addAction(UIAlertAction(title: "Later", style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }

    func presentInvitationView() {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let inviteCode = prefs.valueForKey("gotInvited") as? String {
            LoadingView.showWithMaskType(.Black)
            DataManager.sharedInstance.getInvitationByCode(inviteCode) { (success, errorStr, invitation) in
                LoadingView.dismiss()
                if success {
                    prefs.setValue(nil, forKey: "gotInvited") // clear the dropoff
                    var vc = vcWithID("InviteConfirmVC") as! InviteConfirmVC
                    vc.invitation = invitation as! InvitationModel
                    (self.centerController as! UINavigationController).pushViewController(vc, animated: true)
                } else {
                    if errorStr != "Access Denied" {
                        prefs.setValue(nil, forKey: "gotInvited") // clear the dropoff
                        self.showAlert("Invitation Problem", messege: errorStr, cancleTitle: "OK")
                    }
                }
            }
        }
    }

    func notifyInviteeAcceptance() {
        let prefs = NSUserDefaults.standardUserDefaults()
        let carpoolID = prefs.valueForKey("viewInvitees") as! Int
        prefs.setValue(nil, forKey: "viewInvitees") // clear the dropoff

        let alertView = UIAlertController(title: "Incoming", message: "Someone accepted your Carpool Invitation.", preferredStyle: .Alert)

        alertView.addAction(UIAlertAction(title: "View", style: .Default, handler: { (action: UIAlertAction!) in
            let carpool = CarpoolModel()
            carpool.id = carpoolID
            self.presentInviteeAcceptanceView(carpool)
        }))

        alertView.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))

        self.presentViewController(alertView, animated: true, completion: nil)
    }

    func presentInviteeAcceptanceView(carpool: CarpoolModel!) {
        var vc = vcWithID("InviteesVC") as! InviteesVC
        vc.carpool = carpool
        (self.centerController as! UINavigationController).pushViewController(vc, animated: true)
    }

    func refreshCurrentVC(animated: Bool) {
        (self.centerController as! UINavigationController).visibleViewController.viewDidAppear(animated)
    }

}
