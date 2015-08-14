//
//  SignInVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class SignInVC: BaseVC, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var passwordTextField: PaddingTextField!
    @IBOutlet weak var fbloginButton: FBSDKLoginButton!

    var parentVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        self.registerForKeyBoardNotification()

        emailTextField.keyboardType = .EmailAddress
    }

    func afterSignIn() {
        (self.parentVC as! MainStackVC).refreshCurrentVC(false)
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
                _self.parentVC.dismissViewControllerAnimated(true, completion: self.afterSignIn)
            } else {
                _self.showAlert("Failed to sign in", messege: errorStr, cancleTitle: "OK")
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
            self.showAlert("Failed to sign in with Facebook", messege:error.localizedDescription , cancleTitle: "OK")
        } else if (result.isCancelled) {
            self.showAlert("Failed to sign in with Facebook", messege:"You cancelled login" , cancleTitle: "OK")
        } else {
            if result.grantedPermissions.contains("email") {
                println("success")
                LoadingView.showWithMaskType(.Black)
                dataManager.fbSignin() { (success, errorStr) in
                    LoadingView.dismiss()
                    if success {
                        self.parentVC.dismissViewControllerAnimated(true, completion: self.afterSignIn)
                    } else {
                        self.showAlert("Failed to sign in with Facebook", messege:errorStr , cancleTitle: "OK")
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    // MARK: TextField Delegate
    // --------------------------------------------------------------------------------------------

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
            return false
        }

        if textField == self.passwordTextField {
            self.rightNavButtonTapped()
            return false
        }

        return true
    }

}
