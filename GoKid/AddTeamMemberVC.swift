//
//  AddTeamMemberVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class AddTeamMemberVC: BaseTVC, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    var doneButtonHandler: ((AddTeamMemberVC)->())?
    var removeButtonHandler: ((AddTeamMemberVC)->())?
    
    var selectedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setRemoveButtonState()
        setupSubViews()
        refreshUIIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
    }
    
    func setupNavBar() {
        setNavBarRightButtonTitle("save", action: "handleSaveButtonClick")
    }
    
    func setRemoveButtonState() {
        if model.role != "sitter" {
            buttomButton.backgroundColor = UIColor.grayColor()
            buttomButton.superview?.backgroundColor = UIColor.grayColor()
        }
    }
    
    func setupSubViews() {
        profileImageView.setRounded()
    }
    
    func refreshUIIfNeeded() {
        self.firstNameTextField.text = model.firstName
        self.lastNameTextField.text = model.lastName
        self.phoneNumberTextField.text = model.phoneNumber
        self.roleButton.setTitle(model.role, forState: .Normal)
        self.imageManager.setImageToView(profileImageView, urlStr: model.thumURL)
        
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
                    selectedImage = image
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var row = indexPath.row
        var section = indexPath.section
        
        if model.role.lowercaseString == "kid" {
            if section == 1 { return 0.0 }
            if section == 3 && row == 1 { return 0.0 }
        }
        if section == 0 && row == 0 { return 86.0 }
        if section == 4 { return 60.0 }
        return 44.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if model.role.lowercaseString == "kid" {
            if section == 1 { return 0.0 }
        }
        if section == 0 { return 0.0 }
        return 25.0
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func profileImageButtonClick(sender: AnyObject) {
        setStatusBarColorDark()
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
                self.model.role = title.lowercaseString
                self.tableView.reloadData()
            }
            alert.addAction(button)
        }
        let cancleButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in }
        alert.addAction(cancleButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttomButtonClick(sender: AnyObject) {
        if sourceCellType == .EditMember {
            if model.role.lowercaseString == "sitter" {
                showDeleteMemberAlertView()
            } else {
                self.showAlert("Can not delete", messege: "You can only delete a member whose role is sitter", cancleTitle: "OK")
            }
            return
        }
        handleSaveButtonClick()
    }
    
    func handleSaveButtonClick() {
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
    
    func handleEditOrAddSuccess(success: Bool, errorStr: String, newModel: TeamMemberModel?) {
        if success {
            if let newUser = newModel {
                self.model = newUser
                checkNeedsToUploadImage()
            } else {
                LoadingView.dismiss()
                self.showAlert("Alert", messege: "Success to create user but got no result back from sever", cancleTitle: "OK")
            }
        } else {
            LoadingView.dismiss()
            self.showAlert("Alert", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func checkNeedsToUploadImage() {
        if let image = selectedImage {
            dataManager.upLoadTeamMemberImage(image, model: model, comp: handleUploadImage)
        } else {
            LoadingView.dismiss()
            self.doneButtonHandler?(self)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func handleUploadImage(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        onMainThread() {
            if success {
                self.doneButtonHandler?(self)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.showAlert("Fail to upload Image", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func getTeamModel() -> TeamMemberModel? {
        if let firstName = firstNameTextField.text,
            lastName = lastNameTextField.text,
            role = roleButton.titleLabel?.text,
            phoneNumber = phoneNumberTextField.text {
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
        var alertView = UIAlertView(title: "Alert", message: "Do you want to delete this member?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Confirm")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            removeButtonHandler?(self)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: Text Field Delegate
    // --------------------------------------------------------------------------------------------
    
    @IBAction func firstNameEditingChanged(sender: UITextField) {
        model.firstName = sender.text
    }

    @IBAction func lastNameEditingChanged(sender: UITextField) {
        model.lastName = sender.text
    }
    
    @IBAction func phoneNumberEditingChanged(sender: UITextField) {
        model.phoneNumber = sender.text
    }
    
}
