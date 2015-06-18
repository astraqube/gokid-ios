//
//  MemberProfileVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MemberProfileVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var roleButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var model = TeamMemberModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        refreshUIIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("Your profile")
        setNavBarRightButtonTitle("Save", action: "saveButtonClick")
    }
    
    func refreshUIIfNeeded() {
        self.firstNameTextField.text = model.firstName
        self.lastNameTextField.text = model.lastName
        self.phoneNumberLabel.text = model.phoneNUmber
        self.roleButton.setTitle(model.role, forState: .Normal)
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    // --------------------------------------------------------------------------------------------
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == String(kUTTypeImage) {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    profileImageView.image = image
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func removeButtonClick(sender: AnyObject) {
        
    }
    
    @IBAction func imageProfileButtonClick(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func roleButtonClicked(sender: AnyObject) {
        let button1 = UIAlertAction(title: "Mommy", style: .Default) { (alert) in
            self.roleButton.setTitle("Mommy", forState: .Normal)
        }
        let button2 = UIAlertAction(title: "Daddy", style: .Default) { (alert) in
            self.roleButton.setTitle("Daddy", forState: .Normal)
        }
        let button3 = UIAlertAction(title: "Child", style: .Default) { (alert) in
            self.roleButton.setTitle("Child", forState: .Normal)
        }
        let button4 = UIAlertAction(title: "Sitter", style: .Default) { (alert) in
            self.roleButton.setTitle("Sitter", forState: .Normal)
        }
        let button5 = UIAlertAction(title: "Cancle", style: .Cancel) { (alert) in }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(button1)
        alert.addAction(button2)
        alert.addAction(button3)
        alert.addAction(button4)
        alert.addAction(button5)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhoneVerification" {
            var des = segue.destinationViewController as! Phone_VC
            des.memberProfileVC = self
        }
    }
}
