//
//  MemberProfileVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MemberProfileVC: BaseFormVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private enum Tags : String {
        case FirstName = "First Name"
        case LastName = "Last Name"
        case Email = "Email"
        case Password = "Password"
        case Role = "Role"
        case Phone = "Phone #"
        case CanManage = "Can edit and manage events"
        case Driver = "Driver"
        case EmailNotification = "Email Notification"
        case SMSNotification = "SMS Notification"
        case PushNotification = "Push Notification"
        case AllTeamNotification = "All Team Notification"
        case IllBeDrivingNotification = "I'll be driving Notification"
        case Logout = "Logout"
        case RemoveMember = "Remove Member"
    }

//    @IBOutlet weak var emailLogoutButton: UIButton!
//    @IBOutlet weak var fblogoutButton: FBSDKLoginButton!
//    @IBOutlet weak var fbloginButton: FBSDKLoginButton!
//    @IBOutlet weak var firstNameTextField: UITextField!
//    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var phoneNumberLabel: UILabel!
//    @IBOutlet weak var phoneNumberTextField: PaddingTextField!
//    @IBOutlet weak var roleButton: UIButton!
//    @IBOutlet weak var emailTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!

    var doneButtonHandler: ((MemberProfileVC)->())?
    var removeButtonHandler: ((MemberProfileVC)->())?

    var sourceCellType: TeamCellType = .None
    var sourceCellIndex: Int = 0

    var model: TeamMemberModel! = TeamMemberModel()
    var pickedNewImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()

        if model.thumURL != "" && profileImageView.image == nil {
            ImageManager.sharedInstance.setImageToView(profileImageView, urlStr: model.thumURL)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // require user session
        self.requireSession()
    }

    func requireSession() {
        if self.userManager.userLoggedIn == false {
            self.postNotification("requestForUserToken")
        }
    }

    func setupNavBar() {
        if sourceCellType == .AddMember {
            setNavBarTitle("Add Member")
        } else if sourceCellType == .EditMember {
            setNavBarTitle("Edit Member")
        } else if sourceCellType == .EditUser {
            setNavBarTitle("Your Profile")
        }
        setNavBarRightButtonTitle("Save", action: "rightNavButtonTapped")
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.Role.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: Tags.Role.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        row.selectorOptions = [RoleTypeParent, RoleTypeChild, RoleTypeCareTaker]
        row.value = model.role
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.FirstName.rawValue, rowType: XLFormRowDescriptorTypeName, title: Tags.FirstName.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.required = true
        row.value = model.firstName
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.LastName.rawValue, rowType: XLFormRowDescriptorTypeName, title: Tags.LastName.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.required = true
        row.value = model.lastName
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Email.rawValue, rowType: XLFormRowDescriptorTypeEmail, title: Tags.Email.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.value = model.email
        row.required = sourceCellType == .EditUser
        row.hidden = sourceCellType != .EditUser
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Password.rawValue, rowType: XLFormRowDescriptorTypePassword, title: Tags.Password.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.hidden = sourceCellType != .EditUser
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: Tags.Phone.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.value = model.phoneNumber
        row.hidden = sourceCellType == .EditMember
        section.addFormRow(row)

        if sourceCellType == .EditUser {
            section.footerTitle = "You'll be notified when it's your turn to drive, your kids have arrived safely and when other parents are talking to you."
        }

        form.addFormSection(section)
/*

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.CanManage.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.CanManage.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Driver.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.Driver.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        form.addFormSection(section)

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.EmailNotification.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.EmailNotification.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.SMSNotification.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.SMSNotification.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.PushNotification.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.PushNotification.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        form.addFormSection(section)

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.AllTeamNotification.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.AllTeamNotification.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.IllBeDrivingNotification.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.IllBeDrivingNotification.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        // row.value =
        section.addFormRow(row)

        form.addFormSection(section)
*/

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        if sourceCellType == .EditUser {
            row = XLFormRowDescriptor(tag: Tags.Logout.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.Logout.rawValue)
            row.cellConfig["textLabel.font"] = fontValue
            row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
            row.cellConfigAtConfigure["backgroundColor"] = colorManager.colorDangerRed
            row.action.formSelector = "logout:"
            section.addFormRow(row)
        }

        if sourceCellType == .EditMember {
            row = XLFormRowDescriptor(tag: Tags.RemoveMember.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.RemoveMember.rawValue)
            row.cellConfig["textLabel.font"] = fontValue
            row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
            row.cellConfigAtConfigure["backgroundColor"] = colorManager.colorDangerRed
            row.action.formSelector = "removeMember:"
            section.addFormRow(row)
        }

        form.addFormSection(section)

        self.form = form
        self.form.delegate = self

        self.fieldReactorRole(self.model.role == RoleTypeChild)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        var formRow = self.form.formRowAtIndex(indexPath)

        if formRow!.tag == Tags.Phone.rawValue && sourceCellType == .EditUser {
            self.alertPhoneEdit(formRow)
        }
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.Role.rawValue {
            self.fieldReactorRole((newValue as! String) == RoleTypeChild)
        }

        self.toggleRightNavButtonState()
    }

    // MARK: Field Reactors

    func fieldReactorRole(condition: Bool) {
        /*
        let canManageCell = self.form.formRowWithTag(Tags.CanManage.rawValue)
        let driverCell = self.form.formRowWithTag(Tags.Driver.rawValue)
        let illBeDrivingCell = self.form.formRowWithTag(Tags.IllBeDrivingNotification.rawValue)

        canManageCell?.hidden = condition
        driverCell?.hidden = condition
        illBeDrivingCell?.hidden = condition

        self.updateFormRow(canManageCell)
        self.updateFormRow(driverCell)
        self.updateFormRow(illBeDrivingCell)
        */
    }

    // MARK: UIImagePickerControllerDelegate
    // --------------------------------------------------------------------------------------------
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == String(kUTTypeImage) {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    profileImageView.image = image
                    pickedNewImage = true
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------

    @IBAction func imageProfileButtonClick(sender: AnyObject) {
        setStatusBarColorDark()
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    override func rightNavButtonTapped() {
        let validationErrors: Array<NSError> = self.formValidationErrors() as! Array<NSError>

        if validationErrors.count > 0 {
            self.showFormValidationError(validationErrors.first)
            return
        }

        self.tableView.endEditing(true)

        self.saveProfile()
    }

    private func saveProfile() {
        if sourceCellType == .AddMember {
            self.createMember()
        } else if sourceCellType == .EditMember {
            self.updateMember()
        } else if sourceCellType == .EditUser {
            self.updateUser()
        }
    }

    // MARK: Facebook Login
    // --------------------------------------------------------------------------------------------

    func logout(sender: XLFormRowDescriptor) {
        self.deselectFormRow(sender)
        FBSDKLoginManager().logOut()
        UserManager.sharedInstance.logoutUser()

        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainController = appDelegate.window!.rootViewController as! MainStackVC
        mainController.setWelcomeView()
    }

    func removeMember(sender: XLFormRowDescriptor) {
        self.deselectFormRow(sender)
        removeButtonHandler!(self)
    }

    // MARK: Helper Method
    // --------------------------------------------------------------------------------------------
    
    func updateUser() {
        LoadingView.showWithMaskType(.Black)
        let signupForm = getSignupForm()
        dataManager.updateUser(signupForm, comp: handleUpdateOrCreateUserSuccess)
    }

    func createMember() {
        LoadingView.showWithMaskType(.Black)
        let memberForm = getMemberForm()
        dataManager.addTeamMember(memberForm, comp: handleUpdateOrCreateMemberSuccess)
    }

    func updateMember() {
        LoadingView.showWithMaskType(.Black)
        let memberForm = getMemberForm()
        dataManager.updateTeamMember(memberForm, comp: handleUpdateOrCreateMemberSuccess)
    }

    func handleUpdateOrCreateUserSuccess(success: Bool, errorStr: String) {
        if success {
            if self.pickedNewImage {
                self.uploadUserProfileImage()
            } else {
                onMainThread() {
                    LoadingView.dismiss()
                    self.doneButtonHandler?(self)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            LoadingView.dismiss()
            self.showAlert("Failed to update", messege:errorStr , cancleTitle: "OK")
        }
    }
    
    func handleUpdateOrCreateMemberSuccess(success: Bool, errorStr: String, newModel: AnyObject?) {
        if success {
            self.model = newModel as! TeamMemberModel
            if self.pickedNewImage {
                self.uploadMemberProfileImage()
            } else {
                onMainThread() {
                    LoadingView.dismiss()
                    self.doneButtonHandler?(self)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            LoadingView.dismiss()
            self.showAlert("Failed to update", messege: errorStr, cancleTitle: "OK")
        }
    }

    func uploadUserProfileImage() {
        if let image = profileImageView.image {
            dataManager.upLoadImage(image, comp: handleUploadImageResult)
        }
    }
    
    func uploadMemberProfileImage() {
        if let image = profileImageView.image {
            dataManager.upLoadTeamMemberImage(image, model: self.model, comp: handleUploadImageResult)
        }
    }

    func handleUploadImageResult(success: Bool, errorStr: String) {
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
    
    func getSignupForm() -> SignupForm {
        let formData = self.form.formValues()
        var signupForm = SignupForm()

        if let password = formData[Tags.Password.rawValue] as? String {
            signupForm.passwordConfirm = password
            signupForm.password = password
        }

        signupForm.firstName = formData[Tags.FirstName.rawValue] as! String
        signupForm.lastName = formData[Tags.LastName.rawValue] as! String
        signupForm.phoneNum = formData[Tags.Phone.rawValue] as! String
        signupForm.email = formData[Tags.Email.rawValue] as! String
        signupForm.role = formData[Tags.Role.rawValue] as! String
        return signupForm
    }

    func getMemberForm() -> TeamMemberModel {
        let formData = self.form.formValues()

        self.model.firstName = formData[Tags.FirstName.rawValue] as! String
        self.model.lastName = formData[Tags.LastName.rawValue] as! String
        self.model.role = formData[Tags.Role.rawValue] as! String

        if let phone = formData[Tags.Phone.rawValue] as? String {
            self.model.phoneNumber = phone
        }

        return self.model
    }
}

extension MemberProfileVC {

    // MARK: Phone Editing and Verification

    private func alertPhoneEdit(fieldCell: XLFormRowDescriptor!) {
        let confirmPrompt = UIAlertController(title: "Enter Your Phone", message: nil, preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.text = fieldCell.value as! String
            textField.placeholder = "Phone Number"
        }

        confirmPrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        confirmPrompt.addAction(UIAlertAction(title: "Submit", style: .Default, handler: { (alert: UIAlertAction!) in
            if let textField = confirmPrompt.textFields?.first as? UITextField{
                self.checkPhone(textField.text)
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
    }

    private func alertPhoneVerification(phone: String) {
        if phone == "" { return }

        var msg = "We have sent a verification code to ###. Please check your phone."
        msg = msg.replace("###", phone)

        let confirmPrompt = UIAlertController(title: "Verify Your Phone", message: msg, preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "enter code"
        }

        confirmPrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert: UIAlertAction!) in
            self.setPhoneField(nil)
        }))

        confirmPrompt.addAction(UIAlertAction(title: "Verify", style: .Default, handler: { (alert: UIAlertAction!) in
            if let textField = confirmPrompt.textFields?.first as? UITextField{
                self.verifyPhone(textField.text)
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
    }

    private func checkPhone(phone: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.requestVerificationCode(phone) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.alertPhoneVerification(phone)
                self.setPhoneField(phone)
            } else {
                self.showAlert("Failed to Submit", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    private func verifyPhone(verification: String) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.memberPhoneVerification(verification) { (success, errorStr) in
            if success {
                LoadingView.showSuccessWithStatus("Success")
            } else {
                LoadingView.dismiss()
                self.showAlert("Verification Failed", messege: errorStr, cancleTitle: "OK")
                self.setPhoneField(nil)
            }
        }
    }

    private func setPhoneField(newNumber: String?) {
        let phoneCell = self.form.formRowWithTag(Tags.Phone.rawValue)

        if newNumber != nil {
            phoneCell!.value = newNumber!
        } else {
            phoneCell!.value = self.model.phoneNumber
        }

        self.tableView.reloadData()
    }

}
