//
//  OnboardVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class OnboardVC: BaseVC, UIAlertViewDelegate {
    
    typealias OVC = OnboardingContentViewController
    var contentVC: OnboardingViewController?
    var lastOnBoardVC : LastOnboardVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        addOnboardContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorDark()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.userManager.userLoggedIn {
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainController = appDelegate.window!.rootViewController as! MainStackVC
            mainController.determineStateForViews()
        }
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
        self.postNotification("requestForUserToken")
    }
    
    func goNowButtonHandler() {
        showAlertView()
    }
    
    func joinNowButtonHandler() {
        var invitedInfoVC = vcWithID("InviteInfoVC")
        self.navigationController?.pushViewController(invitedInfoVC, animated: true)
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showAlertView() {
        var alertView = UIAlertView(title: "Are you 18 years old or older?", message: "Only adults over 18 can organize and create carpools", delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var um = UserManager.sharedInstance
        var presentVC: UIViewController!

        if buttonIndex == 0 { // yes
            um.over18 = true
            presentVC = vcWithID("BasicInfoVC")
        } else { // no
            um.over18 = false
            presentVC = vcWithID("KidAboutYouVC")
        }

        self.navigationController?.pushViewController(presentVC, animated: true)
    }
    
    // MARK: Generate OnboardVC
    // --------------------------------------------------------------------------------------------
    
    func generateOnboardContents() -> [OnboardingContentViewController] {
        var page1 = OVC(title:"", body:"", image:UIImage(named: "OnBoarding_1"), buttonText: "") { }
        var page2 = OVC(title:"", body:"", image:UIImage(named: "OnBoarding_2"), buttonText: "") { }
        var page3 = OVC(title:"", body:"", image:UIImage(named: "OnBoarding_3"), buttonText: "") { }
        var page4 = OVC(title:"", body:"", image:UIImage(named: ""),             buttonText: "") { }
        
        page1.topPadding = 0
        page2.topPadding = 0
        page3.topPadding = 0
        page4.topPadding = 0
        
        lastOnBoardVC = vcWithID("LastOnboardVC") as! LastOnboardVC
        lastOnBoardVC.goNowButtonHandler = goNowButtonHandler
        lastOnBoardVC.joinNowButtonHandler = joinNowButtonHandler
        page4.view.addSubview(lastOnBoardVC.view)
        
        return [page1, page2, page3, page4]
    }
    
    
    func generateOnboardVC() -> OnboardingViewController {
        var dark = UIColor.blackColor()
        var contents = generateOnboardContents()
        
        var onboardingVC = OnboardingViewController(backgroundImage: nil, contents: contents)
        onboardingVC.view.backgroundColor = UIColor.whiteColor()
        onboardingVC.shouldFadeTransitions = false
        onboardingVC.fadePageControlOnLastPage = false
                
        var h: CGFloat = 50.0
        var um = UserManager.sharedInstance
        var vh = um.windowH
        var vw = um.windowW
        var rect = CGRectMake(0, vh-h, vw, h)
        
        var signinButton = UIButton(frame: rect)
        signinButton.backgroundColor = UIColor.clearColor()
        signinButton.setTitleColor(colorManager.appDarkGreen, forState: .Normal)
        signinButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        signinButton.setTitle("   Sign in   ", forState: .Normal)
        signinButton.addTarget(self, action: "signInButtonClicked:", forControlEvents: .TouchUpInside)
        signinButton.layer.borderColor = colorManager.appDarkGreen.CGColor
        signinButton.layer.borderWidth = 2.0
        signinButton.layer.cornerRadius = 3.0
        onboardingVC.view.addSubview(signinButton)
        signinButton.autoPinEdgeToSuperviewEdge(.Right, withInset: 20)
        signinButton.autoPinEdgeToSuperviewEdge(.Top, withInset: 25)

        var s = onboardingVC.pageControl.frame.size
        var o = onboardingVC.pageControl.frame.origin
        var pageControlRect = CGRectMake(o.x, o.y-50, s.width, s.height)
        onboardingVC.pageControl.frame = pageControlRect
        onboardingVC.pageControl.pageIndicatorTintColor = colorManager.darkGrayColor
        onboardingVC.pageControl.currentPageIndicatorTintColor = dark
        return onboardingVC
    }
}
