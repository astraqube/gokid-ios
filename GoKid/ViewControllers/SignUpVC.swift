//
//  SignUpVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignUpVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lastNameTextField: PaddingTextField!
    @IBOutlet weak var firstNameTextField: PaddingTextField!
    @IBOutlet weak var emailTextField: PaddingTextField!
    @IBOutlet weak var passwordTextField: PaddingTextField!
    var backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    func setupSubviews() {
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0.85
        view.backgroundColor = UIColor.clearColor()
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        
        profileImageView.backgroundColor = UIColor.grayColor()
        profileImageView.layer.cornerRadius = profileImageView.w/2.0
        profileImageView.userInteractionEnabled = false
        profileImageView.clipsToBounds = true
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
        view.alphaAnimation(0.0, duration: 0.5) { (anim, finished) in
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
        userManager.userProfileImage = profileImageView.image
        userManager.userFirstName = firstNameTextField.text
        userManager.userLastName = lastNameTextField.text
        userManager.userEmail = emailTextField.text
        
        NSNotificationCenter.defaultCenter().postNotificationName("SignupFinished", object: nil)
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
    
    // MARK: Dismiss keyboard when touch
    // --------------------------------------------------------------------------------------------
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
}
