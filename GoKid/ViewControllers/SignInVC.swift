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

    var parentVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        self.registerForKeyBoardNotification()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------

    override func leftNavButtonTapped() {
        self.parentVC.dismissViewControllerAnimated(true, completion: nil)
    }

    override func rightNavButtonTapped() {
        let _self = self
        var email = emailTextField.text
        var passw = passwordTextField.text
        LoadingView.showWithMaskType(.Black)
        dataManager.signin(email, password: passw) { (success, errorStr) -> () in
            LoadingView.dismiss()
            if success {
                _self.parentVC.dismissViewControllerAnimated(true) {
                    _self.signinSuccessHandler?()
                }
            } else {
                _self.showAlert("Sign In Failed", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        (self.parentVC as! MainStackVC).popUpSignUpView()
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
                LoadingView.showWithMaskType(.Black)
                dataManager.fbSignin() { (success, errorStr) in
                    LoadingView.dismiss()
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
    
    // MARK: TextField Delegate
    // --------------------------------------------------------------------------------------------

    @IBAction func emailTextFieldReturn(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }

    @IBAction func passwordTextFieldReturn(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }

}
