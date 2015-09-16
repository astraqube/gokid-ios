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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        rightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)

        // Get rid of navbar border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
        self.view.endEditing(true)
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
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
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
