//
//  MainStackVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MainStackVC: IIViewDeckController, UIAlertViewDelegate {
    
    var colorManager = ColorManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var meneVC = vcWithID("MenuVC") as! MenuVC
        meneVC.mainStack = self
        self.leftController = meneVC
        self.leftSize = 100
        
        
        var centerVC = UINavigationController()
        centerVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        centerVC.navigationBar.barTintColor = UIColor.blackColor()
        centerVC.navigationBar.tintColor = UIColor.whiteColor()
        centerVC.navigationBar.backgroundColor = UIColor.blackColor()

        centerVC.navigationBarHidden = true
        self.centerController = centerVC
                
        var onboardVC = generateOnboardVC()
        centerVC.pushViewController(onboardVC, animated: false)
    }
    
    func generateOnboardVC() -> OnboardingViewController {
        var dark = UIColor.blackColor()
        
        var firstPage = OnboardingContentViewController(title: "Easy and Safe", body: "Making carpooling easier and more efficient. Live tracking and mapping shows where your kids are, where thry are going , and where they will be home", image: UIImage(named: "blue"), buttonText: "") {
        }
        var secondPage = OnboardingContentViewController(title: "Save Gas and Cash", body: "Carpooling saves time, and money. The more you carpool, the more save.", image: UIImage(named: "blue"), buttonText: "") {
        }
        var thirdPage = OnboardingContentViewController(title: "Save Mother Earth", body: "Carpooling is a greate way to work with your community to reduce emissions and teach kids about being green. Together we can do this better.", image: UIImage(named: "blue"), buttonText: "") {
        }
        
        thirdPage.viewWillAppearBlock = {
            var font = UIFont.systemFontOfSize(17, weight: 20)
            
            var startedButtonRect = CGRectMake(50, 400, 280, 40)
            var startedButton = UIButton(frame: startedButtonRect)
            startedButton.backgroundColor = self.colorManager.darkGrayColor
            startedButton.titleLabel?.font = font
            startedButton.setTitle("Let's get started", forState: .Normal)
            startedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            startedButton.addTarget(self, action: "getStartedButtonClick:", forControlEvents: .TouchUpInside)
            thirdPage.view.addSubview(startedButton)
            
            var carpoolButtonRect = CGRectMake(50, 450, 280, 40)
            var carpoolButton = UIButton(frame: carpoolButtonRect)
            carpoolButton.backgroundColor = self.colorManager.darkGrayColor
            carpoolButton.titleLabel?.font = font
            carpoolButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            carpoolButton.setTitle("Already invited to a carpool?", forState: .Normal)
            carpoolButton.addTarget(self, action: "alreadyCarpoolButtonClicked:", forControlEvents: .TouchUpInside)
            thirdPage.view.addSubview(carpoolButton)
        }
        
        var bgImage = UIImage(named: "gray-bg")
        var contents = [firstPage, secondPage, thirdPage]
        
        var onboardingVC = OnboardingViewController(backgroundImage: bgImage, contents: contents)
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.bodyTextColor = dark
        onboardingVC.titleTextColor = dark
        onboardingVC.titleFontSize = 29
        onboardingVC.bodyFontSize = 21
        
        firstPage.view.backgroundColor = colorManager.lightGrayColor
        secondPage.view.backgroundColor = colorManager.lightGrayColor
        thirdPage.view.backgroundColor = colorManager.lightGrayColor
        
        var h: CGFloat = 50.0
        var um = UserManager.sharedInstance
        var vh = um.windowH
        var vw = um.windowW
        var rect = CGRectMake(0, vh-h, vw, h)
        
        var signinButton = UIButton(frame: rect)
        signinButton.backgroundColor = colorManager.darkGrayColor
        signinButton.titleLabel?.textColor = UIColor.blackColor()
        signinButton.setTitle("Already have an account? Sign in", forState: .Normal)
        signinButton.addTarget(self, action: "signInButtonClicked:", forControlEvents: .TouchUpInside)
        onboardingVC.view.addSubview(signinButton)
        
        var s = onboardingVC.pageControl.frame.size
        var o = onboardingVC.pageControl.frame.origin
        var pageControlRect = CGRectMake(o.x, o.y-100, s.width, s.height)
        onboardingVC.pageControl.frame = pageControlRect
        onboardingVC.pageControl.pageIndicatorTintColor = colorManager.darkGrayColor
        onboardingVC.pageControl.currentPageIndicatorTintColor = dark
        return onboardingVC
    }
    
    func showAlertView() {
        var alertView = UIAlertView(title: "Are you 18 years old or older?", message: "Only adults over 18 can organize and create carpools", delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var um = UserManager.sharedInstance
        var navVC = self.centerController as! UINavigationController
        if buttonIndex == 0 {
            um.over18 = true
            var infoVC = vcWithID("BasicInfoVC")
            var calendarVC = vcWithID("CalendarVC")
            var arr = [calendarVC, infoVC]
            navVC.setViewControllers(arr, animated: true)
            return
        } else { // children
            um.over18 = false
            var vc = vcWithID("KidAboutYouVC")
            navVC.pushViewController(vc, animated: true)
        }
    }
    
    func signInButtonClicked(button: UIButton) {
        var signInVC = vcWithID("SignInVC")
        var navVC = self.centerController as! UINavigationController
        navVC.pushViewController(signInVC, animated: true)
    }
    
    func getStartedButtonClick(button: UIButton) {
        showAlertView()
    }
    
    func alreadyCarpoolButtonClicked(button: UIButton) {
        var invitedInfoVC = vcWithID("InviteInfoVC")
        var navVC = self.centerController as! UINavigationController
        navVC.pushViewController(invitedInfoVC, animated: true)
    }
}
