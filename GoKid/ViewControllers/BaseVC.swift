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
    
    var keyBoardMoveUp : CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyBoardNotification()
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
    
    func setNavBarRightButtonTitle(title: String, action: Selector) {
        var rightButton = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func setNavBarLeftButtonTitle(title: String, action: Selector) {
        var leftButton = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showAlert(title: String, messege: String, cancleTitle: String) {
        var alertView = UIAlertView(title: title, message: messege, delegate: self, cancelButtonTitle: cancleTitle)
        alertView.show()
    }
}




