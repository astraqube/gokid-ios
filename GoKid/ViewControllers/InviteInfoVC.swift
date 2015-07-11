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
        // round profile image view
        profileImageView.setRounded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorDark()
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
            proceedToNextVC(signupForm)
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
    
    func proceedToNextVC(form: SignupForm) {
        userManager.unregisteredUserInfo = form
        LoadingView.showWithMaskType(.Black)
        dataManager.verifyCarPoolInvitation(form.phoneNum) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.moveToPhoneVerifyVC(form)
            } else {
                self.showAlert("Your Phone Number Doesn't Match", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func moveToPhoneVerifyVC(form: SignupForm) {
        onMainThread() {
            var vc = vcWithID("PhoneVerifyVC") as! PhoneVerifyVC
            vc.fromCarpoolInvite = true
            vc.phoneNumberString = self.phoneNumberTextField.text
            vc.signupForm = form
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getSignupForm() -> SignupForm? {
        if let password = passWordTextField.text,
            phoneNum = phoneNumberTextField.text,
            firstName = firstNameTextField.text,
            lastName = lastNameTextfield.text,
            email = emailTextField.text
        {
            var signupForm = SignupForm()
            signupForm.passwordConfirm = password
            signupForm.password = password
            signupForm.firstName = firstName
            signupForm.lastName = lastName
            signupForm.email = email
            signupForm.phoneNum = phoneNum
            signupForm.image = profileImageView.image
            return signupForm
        }
        return nil
    }
}
