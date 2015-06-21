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
    
    var dataManager = DataManager.sharedInstance
    var sourceCellType: TeamCellType = .None
    var sourceCellIndex: Int = 0
    var model = TeamMemberModel()
    
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
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        var titles = ["Mommy", "Daddy", "Kid", "Sitter"]
        for title in titles {
            let button = UIAlertAction(title: title, style: .Default) { (alert) in
                self.roleButton.setTitle(title, forState: .Normal)
            }
            alert.addAction(button)
        }
        let cancleButton = UIAlertAction(title: "Cancle", style: .Cancel) { (alert) in }
        alert.addAction(cancleButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttomButtonClick(sender: AnyObject) {
        if sourceCellType == .EditMember {
            showDeleteMemberAlertView()
            return
        }
        handleDoneButtonClick()
    }
    
    func handleDoneButtonClick() {
        if let model = getTeamModel() {
            LoadingView.showWithMaskType(.Black)
            if sourceCellType == .AddMember {
                dataManager.addTeamMember(model, comp: handleEditOrAddSuccess)
            } else if sourceCellType == .EditMember {
                dataManager.updateTeamMember(model, comp: handleEditOrAddSuccess)
            }
        } else {
            showAlert("Alert", messege: "Please Fill in all the blank field", cancleTitle: "OK")
        }
    }
    
    // MARK: Upload changes
    // --------------------------------------------------------------------------------------------
    
    func handleEditOrAddSuccess(success: Bool, errorStr: String) {
        onMainThread() {
            LoadingView.dismiss()
            if success {
                self.doneButtonHandler?(self)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.showAlert("Alert", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func getTeamModel() -> TeamMemberModel? {
        if let firstName = firstNameTextField.text,
            lastName = lastNameTextField.text,
            role = roleButton.titleLabel?.text,
            phoneNumber = phoneNumberTextField.text {
                var model = TeamMemberModel()
                model.firstName = firstName
                model.lastName = lastName
                model.role = role
                model.phoneNumber = phoneNumber
                return model
        } else {
            return nil
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
