//
//  SignUpVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lastNameTextField: PaddingTextField!
    @IBOutlet weak var firstNameTextField: PaddingTextField!
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var passwordTextField: PaddingTextField!
    @IBOutlet weak var fbloginButton: FBSDKLoginButton!
    
    var backgroundView = UIView()
    var signinButtonHandler: ((Void)->(Void))?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLoginButton()
        setupGuestureRecognizer()
    }
    
    func setupSubviews() {
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0.85
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        
        profileImageView.setRounded()
        profileImageView.backgroundColor = UIColor.grayColor()
        profileImageView.userInteractionEnabled = false
    }
    
    func setupGuestureRecognizer() {
        var tapGR = UITapGestureRecognizer(target: self, action: "backgroundTapped:")
        backgroundView.addGestureRecognizer(tapGR)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func imageButtonClicked(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClick(sender: AnyObject) {
        
        var signupForm = SignupForm()
        signupForm.role = "kid"
        signupForm.email = emailTextField.text
        signupForm.firstName = firstNameTextField.text
        signupForm.lastName = lastNameTextField.text
        signupForm.password = passwordTextField.text
        signupForm.passwordConfirm = passwordTextField.text
        
        dataManager.signup(signupForm) { (success, errorStr) in
            if success {
                self.view.alphaAnimation(0.0, duration: 0.4) { (anim, finished) in
                    self.willMoveToParentViewController(nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                }
            } else {
                self.showAlert("Failed to Signup", messege: errorStr, cancleTitle: "OK")
            }
        }        
    }
    
    @IBAction func signinButtonClick(sender: AnyObject) {
        signinButtonHandler?()
    }
    
    func backgroundTapped(gr: UITapGestureRecognizer) {
        animateRemoveFromParentViewController()
    }
    
    func animateRemoveFromParentViewController() {
        self.view.alphaAnimation(0.0, duration: 0.5) { (anim, finished) in
            onMainThread() {
                //self.willMoveToParentViewController(nil)
                self.view.removeFromSuperview()
                //self.removeFromParentViewController()
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
                        self.animateRemoveFromParentViewController()
                    } else {
                        self.showAlert("Falied to user FB Signup", messege:errorStr , cancleTitle: "OK")
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
}
