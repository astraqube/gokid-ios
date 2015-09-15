//
//  LoginDigitsVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 9/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import DigitsKit

class LoginDigitsVC: BaseVC {

    var parentVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func rightNavButtonTapped() {
        self.parentVC.dismissViewControllerAnimated(true) {
            let digits = Digits.sharedInstance()
            digits.authenticateWithCompletion { (session, error) in
                // Inspect session/error objects
            }
        }
    }

    override func leftNavButtonTapped() {
        self.parentVC.dismissViewControllerAnimated(true, completion: nil)
    }

}
