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
    @IBOutlet weak var passwordTextField: PaddingTextField!
    var signinSuccessHandler: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("Sign In")
        setNavBarRightButtonTitle("Submit", action: "SubmitButtonClicked")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func SubmitButtonClicked() {
        
        var email = emailTextField.text
        var passw = passwordTextField.text
        
        dataManager.signin(email, password: passw) { (success, errorStr) -> () in
            if success {
                self.signinSuccessHandler?()
            } else {
                var str = "An Network error occured"
                if errorStr != nil { str = errorStr! }
                self.showAlert("Sign In Failed", messege: str, cancleTitle: "OK")
            }
        }
    }
}
