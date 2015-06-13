//
//  OnboardVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class OnboardVC: UIViewController, UIAlertViewDelegate {
    
    var colorManager = ColorManager.sharedInstance
    var contentVC: OnboardingViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        addOnboardContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func addOnboardContent() {
        var vc = generateOnboardVC()

        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
        contentVC = vc
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func signInButtonClicked(button: UIButton) {
        var signInVC = vcWithID("SignInVC") as! SignInVC
        signInVC.signinSuccessHandler = signinSuccess
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    func signinSuccess() {
        var calendarVC = vcWithID("CalendarVC")
        self.navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    func getStartedButtonClick(button: UIButton) {
        showAlertView()
    }
    
    func alreadyCarpoolButtonClicked(button: UIButton) {
        var invitedInfoVC = vcWithID("InviteInfoVC")
        navigationController?.pushViewController(invitedInfoVC, animated: true)
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showAlertView() {
        var alertView = UIAlertView(title: "Are you 18 years old or older?", message: "Only adults over 18 can organize and create carpools", delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var um = UserManager.sharedInstance
        if buttonIndex == 0 {
            um.over18 = true
            var infoVC = vcWithID("BasicInfoVC")
            var calendarVC = vcWithID("CalendarVC")
            var arr = [calendarVC, infoVC]
            navigationController?.setViewControllers(arr, animated: true)
            return
        } else { // children
            um.over18 = false
            var vc = vcWithID("KidAboutYouVC")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Generate OnboardVC
    // --------------------------------------------------------------------------------------------
    
    func generateOnboardContents() -> [OnboardingContentViewController] {
        var firstPage = OnboardingContentViewController(title: "Easy and Safe", body: "Making carpooling easier and more efficient. Live tracking and mapping shows where your kids are, where they are going, and when they will be home", image: UIImage(named: "blue"), buttonText: "") {
        }
        var secondPage = OnboardingContentViewController(title: "Save Gas and Cash", body: "Carpooling saves time and money. The more you carpool, the more save.", image: UIImage(named: "blue"), buttonText: "") {
        }
        var thirdPage = OnboardingContentViewController(title: "Save Mother Earth", body: "Carpooling is a great way to work with your community to reduce emissions and teach kids about being green. Together we can do this better.", image: UIImage(named: "blue"), buttonText: "") {
        }
        
        thirdPage.viewWillAppearBlock = {
            var font = UIFont.systemFontOfSize(17, weight: 20)
            
            var X_Co = self.view.frame.size.width/2-280/2
            var Y_Co = self.view.frame.size.height

            
            var startedButtonRect = CGRectMake(X_Co, Y_Co-175, 280, 40)
            var startedButton = UIButton(frame: startedButtonRect)
            startedButton.backgroundColor = self.colorManager.darkGrayColor
            startedButton.titleLabel?.font = font
            startedButton.setTitle("Let's get started", forState: .Normal)
            startedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            startedButton.addTarget(self, action: "getStartedButtonClick:", forControlEvents: .TouchUpInside)
            thirdPage.view.addSubview(startedButton)
            
            var carpoolButtonRect = CGRectMake(X_Co, Y_Co-125, 280, 40)
            var carpoolButton = UIButton(frame: carpoolButtonRect)
            carpoolButton.backgroundColor = self.colorManager.darkGrayColor
            carpoolButton.titleLabel?.font = font
            carpoolButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            carpoolButton.setTitle("Already invited to a carpool?", forState: .Normal)
            carpoolButton.addTarget(self, action: "alreadyCarpoolButtonClicked:", forControlEvents: .TouchUpInside)
            thirdPage.view.addSubview(carpoolButton)

        }
        return [firstPage, secondPage, thirdPage]
    }
    
    
    func generateOnboardVC() -> OnboardingViewController {
        var dark = UIColor.blackColor()
        var bgImage = UIImage(named: "gray-bg")
        var contents = generateOnboardContents()
        
        var onboardingVC = OnboardingViewController(backgroundImage: bgImage, contents: contents)
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.bodyTextColor = dark
        onboardingVC.titleTextColor = dark
        onboardingVC.titleFontSize = 29
        onboardingVC.bodyFontSize = 21
        onboardingVC.shouldMaskBackground = false
                
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
        var pageControlRect = CGRectMake(o.x, o.y-50, s.width, s.height)
        onboardingVC.pageControl.frame = pageControlRect
        onboardingVC.pageControl.pageIndicatorTintColor = colorManager.darkGrayColor
        onboardingVC.pageControl.currentPageIndicatorTintColor = dark
        return onboardingVC
    }
}
