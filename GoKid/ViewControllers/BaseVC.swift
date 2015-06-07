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

    override func viewDidLoad() {
        super.viewDidLoad()
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




