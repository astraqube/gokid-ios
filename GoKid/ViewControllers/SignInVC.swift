//
//  SignInVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class SignInVC: BaseVC {
    
    @IBOutlet weak var emailTextField: PaddingTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("Sign In")
        setNavBarRightButtonTitle("Submit", action: "SubmitButtonClicked")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func SubmitButtonClicked() {
        userManager.userName = emailTextField.text
        var calendarVC = vcWithID("CalendarVC")
        navigationController?.pushViewController(calendarVC, animated: true)
    }
}
