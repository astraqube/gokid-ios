//
//  SignUpVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lastNameTextField: PaddingTextField!
    @IBOutlet weak var firstNameTextField: PaddingTextField!
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var passwordTextField: PaddingTextField!
    @IBOutlet weak var fbloginButton: FBSDKLoginButton!

    var parentVC: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        self.registerForKeyBoardNotification()

        firstNameTextField.keyboardType = .ASCIICapable
        lastNameTextField.keyboardType = .ASCIICapable
        emailTextField.keyboardType = .EmailAddress
    }

    func afterSignUp() {
        self.parentVC.dismissViewControllerAnimated(true) {
            (self.parentVC as! MainStackVC).refreshCurrentVC(false)
        }
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        self.parentVC.dismissViewControllerAnimated(true, completion: nil)
    }

    override func rightNavButtonTapped() {
        var signupForm = SignupForm()
        signupForm.email = emailTextField.text
        signupForm.firstName = firstNameTextField.text
        signupForm.lastName = lastNameTextField.text
        signupForm.password = passwordTextField.text
        signupForm.passwordConfirm = passwordTextField.text

        let _self = self
        LoadingView.showWithMaskType(.Black)
        dataManager.signup(signupForm) { (success, errorStr) in
            if success {
                if let avatar = self.profileImageView.image {
                    self.dataManager.upLoadImage(avatar) { (_success, _errorStr) in
                        if _errorStr != "" {
                            self.showAlert("Failed to Sign up", messege: errorStr, cancleTitle: "OK")
                        }
                        LoadingView.dismiss()
                        self.afterSignUp()
                    }
                } else {
                    LoadingView.dismiss()
                    self.afterSignUp()
                }
            } else {
                LoadingView.dismiss()
                self.showAlert("Failed to Sign up", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    @IBAction func imageButtonClicked(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func signInButtonClicked(sender: AnyObject) {
        (self.parentVC as! MainStackVC).popUpSignInView()
    }

    // MARK: Facebook Login
    // --------------------------------------------------------------------------------------------
    func setupLoginButton() {
        self.fbloginButton.readPermissions = ["public_profile", "email", "user_friends"];
        self.fbloginButton.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            self.showAlert("Failed to connect with Facebook", messege:error.localizedDescription , cancleTitle: "OK")
        } else if (result.isCancelled) {
            self.showAlert("Failed to connect with Facebook", messege:"You cancelled login" , cancleTitle: "OK")
        } else {
            if result.grantedPermissions.contains("email") {
                println("success")
                dataManager.fbSignin() { (success, errorStr) in
                    if success {
                        self.afterSignUp()
                    } else {
                        self.showAlert("Failed to connect with Facebook", messege:errorStr , cancleTitle: "OK")
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
      
    }
    
    // MARK: UIImagePickerControllerDelegate
    // --------------------------------------------------------------------------------------------
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == String(kUTTypeImage) {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.profileImageView.image = image
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    // MARK: TextField Delegate
    // --------------------------------------------------------------------------------------------
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.firstNameTextField {
            self.lastNameTextField.becomeFirstResponder()
            return false
        }

        if textField == self.lastNameTextField {
            self.emailTextField.becomeFirstResponder()
            return false
        }

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
