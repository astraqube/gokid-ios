//
//  BaseVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    var dataManager = DataManager.sharedInstance
    var userManager = UserManager.sharedInstance
    var colorManager = ColorManager.sharedInstance
    var imageManager = ImageManager.sharedInstance
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var largeLeftButton: UIButton?
    var largeRightButton: UIButton?
    
    var keyBoardMoveUp : CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        rightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)
        addLargeNavigationButton()

        // Get rid of navbar border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    func addLargeNavigationButton() {
        var buttonW: CGFloat = 40
        var buttonH: CGFloat = 36
        var windowW = userManager.windowW
        largeLeftButton = UIButton(frame: CGRectMake(0.0, 20.0, buttonW, buttonH))
        largeRightButton = UIButton(frame: CGRectMake(windowW-buttonW, 20.0, buttonW, buttonH))
        largeLeftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        largeRightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)
        if leftButton != nil {
            view.insertSubview(largeLeftButton!, belowSubview: leftButton)
        }
        if rightButton != nil {
            view.insertSubview(largeRightButton!, belowSubview: rightButton)
        }
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func leftNavButtonTapped() {
        
    }
    
    func rightNavButtonTapped() {
        
    }
    
    // MARK: Move View up when keyboard shows
    // --------------------------------------------------------------------------------------------
    
    func registerForKeyBoardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= keyBoardMoveUp
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += keyBoardMoveUp
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
}

extension UIViewController {
    
    // MARK: NavigationBar setup
    // --------------------------------------------------------------------------------------------
    
    func setNavBarTitle(title: String) {
        self.title = title
    }
    
    func setNavBarColor(color: UIColor) {
        self.navigationController?.navigationBar.barTintColor = color
    }
    
    func setNavBarTitleAndButtonColor(color: UIColor) {
        self.navigationController?.navigationBar.tintColor = color
    }
    
    func setNavBarRightButtonTitle(title: String, action: Selector) {
        var rightButton = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setNavBarLeftButtonTitle(title: String, action: Selector) {
        var leftButton = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    // MARK: NavigationBar setup
    // --------------------------------------------------------------------------------------------
    
    func setStatusBarColorLight() {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func setStatusBarColorDark() {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showAlert(title: String, messege: String, cancleTitle: String) {
        onMainThread() {
            var alertView = UIAlertView(title: title, message: messege, delegate: self, cancelButtonTitle: cancleTitle)
            alertView.show()
        }
    }
}
