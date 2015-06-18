//
//  SignInVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class SignInVC: BaseVC, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var passwordTextField: PaddingTextField!
    @IBOutlet weak var fbloginButton: FBSDKLoginButton!
    var signinSuccessHandler: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupLoginButton()
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
        LoadingView.showWithMaskType(.Black)
        dataManager.signin(email, password: passw) { (success, errorStr) -> () in
            LoadingView.dismiss()
            if success {
                self.signinSuccessHandler?()
            } else {
                self.showAlert("Sign In Failed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    // MARK: Facebook Login
    // --------------------------------------------------------------------------------------------
    
    func setupLoginButton() {
        self.fbloginButton.readPermissions = ["public_profile", "email", "user_friends"];
        self.fbloginButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            self.showAlert("Falied to user FB Signup", messege:error.localizedDescription , cancleTitle: "OK")
        } else if (result.isCancelled) {
            self.showAlert("Falied to user FB Signup", messege:"You cancled login" , cancleTitle: "OK")
        } else {
            if result.grantedPermissions.contains("email") {
                println("success")
                dataManager.fbSignin() { (success, errorStr) in
                    if success {
                        self.signinSuccessHandler?()
                    } else {
                        self.showAlert("Falied to user FB Signup", messege:errorStr , cancleTitle: "OK")
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
}
