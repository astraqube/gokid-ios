//
//  InviteInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MobileCoreServices

class InviteInfoVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var passWordTextField: PaddingTextField!
    @IBOutlet weak var phoneNumberTextField: PaddingTextField!
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var firstNameTextField: PaddingTextField!
    @IBOutlet weak var lastNameTextfield: PaddingTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        // move view up when keyboard shows
        self.keyBoardMoveUp = 95
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavigationBar() {
        setNavBarTitle("I was invited")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    // MARK: IBAction Mathod
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        if let signupForm = getSignupForm() {
            createUser(signupForm)
        } else {
            showAlert("Alert", messege: "Please Fill in all Blank", cancleTitle: "OK")
        }
    }
    
    @IBAction func chooseImageButtonClick(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
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
    
    // MARK: Network Flow
    // --------------------------------------------------------------------------------------------
    
    func createUser(signupForm: SignupForm) {
        dataManager.signup(signupForm) { (success, errorStr) in
            if success {
                self.fetchInvite()
            } else {
                self.showAlert("Alert", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func fetchInvite() {
        dataManager.getCarpools() { (success, errorStr) in
            if success {
                var vc = vcWithID("PhoneVerifyVC") as! PhoneVerifyVC
                vc.fromCarpoolInvite = true
                vc.phoneNumberString = self.phoneNumberTextField.text
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Alert", messege: "You are not invited by any user", cancleTitle: "OK")
            }
        }
    }
    
    
    func getSignupForm() -> SignupForm? {
        if let password = passWordTextField.text,
            firstName = firstNameTextField.text,
            lastName = lastNameTextfield.text,
            email = emailTextField.text {
                var signupForm = SignupForm()
                signupForm.passwordConfirm = password
                signupForm.password = password
                signupForm.firstName = firstName
                signupForm.lastName = lastName
                signupForm.email = email
                signupForm.role = "kid"
                return signupForm
        }
        return nil
    }
}
