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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "popUpSignInView", name: "requestForUserToken", object: nil)

        self.determineStateForViews()
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

    func setSignedInView() {
        let menuVC = vcWithID("MenuVC") as! MenuVC
        self.leftController = menuVC
        self.leftSize = 100

        self.rootVC = vcWithID("CalendarVC")
        self.centerController = UINavigationController(rootViewController: self.rootVC)
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

    func refreshCurrentVC(animated: Bool) {
        (self.centerController as! UINavigationController).visibleViewController.viewDidAppear(animated)
    }

}
