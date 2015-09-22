//
//  SignInVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import FBSDKLoginKit

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
        let email = emailTextField.text
        let passw = passwordTextField.text
        LoadingView.showWithMaskType(.Black)
        dataManager.signin(email!, password: passw!) { (success, errorStr) -> () in
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

    @IBAction func forgotClicked(sender: AnyObject) {
        let emailPrompt = UIAlertController(title: "Need help?", message: "If you forgot your password, we can send you a link to reset it.", preferredStyle: .Alert)
        emailPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "enter email address"
            textField.keyboardType = .EmailAddress
        }

        emailPrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        emailPrompt.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (alert: UIAlertAction) in
            if let textField = emailPrompt.textFields?.first as UITextField? {
                self.dataManager.resetPassword(textField.text!) { (success, error) -> () in
                    if success {
                        self.showAlert("Instructions Sent!", messege: "Please check your email and follow the instructions there.", cancleTitle: "OK")
                    } else {
                        self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
                    }
                }
            }
        }))

        presentViewController(emailPrompt, animated: true, completion: nil)
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
                print("success", terminator: "")
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
