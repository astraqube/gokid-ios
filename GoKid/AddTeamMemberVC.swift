//
//  AddTeamMemberVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class AddTeamMemberVC: UITableViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var roleButton: UIButton!
    @IBOutlet weak var buttomButton: UIButton!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!

    
    var sourceCellType: TeamCellType = .None
    var sourceCellIndex: Int = 0
    var model = TeamMemberModel()
    
    var teamAccountVC: TeamAccountVC?
    var doneButtonHandler: ((AddTeamMemberVC)->())?
    var removeButtonHandler: ((AddTeamMemberVC)->())?
    
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
        setNavBarRightButtonTitle("Done", action: "handleDoneButtonClick")
    }
    
    func refreshUIIfNeeded() {
        self.firstNameTextField.text = model.firstName
        self.lastNameTextField.text = model.lastName
        self.phoneNumberTextField.text = model.phoneNumber
        self.roleButton.setTitle(model.role, forState: .Normal)
        
        if sourceCellType == .AddUser {
            setNavBarTitle("Add your Profile")
        } else if sourceCellType == .AddMember {
            setNavBarTitle("Add Member")
        } else if sourceCellType == .EditMember {
            setNavBarTitle("Edit Member")
            buttomButton.setTitle("Remove", forState: .Normal)
        } else if sourceCellType == .EditUser {
            setNavBarTitle("Add Member")
        }
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
    
    @IBAction func profileImageButtonClick(sender: AnyObject) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func roleButtonClick(sender: AnyObject) {
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
    
    
    @IBAction func buttomButtonClick(sender: AnyObject) {
        if sourceCellType == .EditMember {
            showDeleteMemberAlertView()
            return
        }
        handleDoneButtonClick()
    }
    
    func getTeamModel() -> TeamMemberModel
    
    func handleDoneButtonClick() {
        if let firstName = firstNameTextField.text,
            lastName = lastNameTextField.text,
            role = roleButton.titleLabel?.text,
            phoneNumber = phoneNumberTextField.text {
                doneButtonHandler?(self)
                navigationController?.popViewControllerAnimated(true)
        } else {
            showAlert("Alert", messege: "Please Fill in all the blank field", cancleTitle: "OK")
        }
    }
    
    // MARK: AlertView
    // --------------------------------------------------------------------------------------------
    
    func showDeleteMemberAlertView() {
        var alertView = UIAlertView(title: "Alert", message: "Do you want to delete this member?", delegate: self, cancelButtonTitle: "Cancle", otherButtonTitles: "Confirm")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            removeButtonHandler?(self)
            navigationController?.popViewControllerAnimated(true)
        }
    }
}
