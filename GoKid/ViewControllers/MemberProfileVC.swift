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
    var sourceCellType: TeamCellType = .None
    var sourceCellIndex: Int = 0
    var model: TeamMemberModel! = TeamMemberModel()
    var pickedNewImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
//        setupTableView()
//        setupLoginButton()
//        setUpLogoutButton()
//        refreshUIIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setStatusBarColorDark()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // require user session
        self.requireSession()

        self.fieldReactorRole(self.model.role == RoleTypeChild)
    }

    func requireSession() {
        if self.userManager.userLoggedIn == false {
            self.postNotification("requestForUserToken")
        } else {
            if self.model.userID == 0 {
                self.model = self.userManager.info
            }

            if self.model.thumURL != "" && self.profileImageView.image == nil {
                ImageManager.sharedInstance.setImageToView(self.profileImageView, urlStr: self.model.thumURL)
            }
        }
    }

    func setupNavBar() {
        setNavBarTitle("Your Profile")
        setNavBarRightButtonTitle("Save", action: "rightNavButtonTapped")
    }
/* DEPRECATED
    func setupLoginButton() {
        fbloginButton.readPermissions = ["public_profile", "email", "user_friends"];
        fbloginButton.delegate = self
    }

    func setUpLogoutButton() {
        fblogoutButton.delegate = self
        if userManager.useFBLogIn {
            emailLogoutButton.removeFromSuperview()
        } else {
            fblogoutButton.removeFromSuperview()
        }
    }

    func setupTableView() {
        tableView.delegate = self
    }

    func refreshUIIfNeeded() {
        self.firstNameTextField.text = model.firstName
        self.lastNameTextField.text = model.lastName
        self.phoneNumberLabel.text = model.phoneNumber
        self.emailTextField.text = model.email
        self.roleButton.setTitle(model.role, forState: .Normal)
        self.passwordTextField.text = model.passWord
        ImageManager.sharedInstance.setImageToView(profileImageView, urlStr: model.thumURL)
    }
*/
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
        row.selectorOptions = [RoleTypeParent, RoleTypeDaddy, RoleTypeMommy, RoleTypeChild, RoleTypeCareTaker, RoleTypeOther]
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
        row.required = true
        row.value = model.email
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Password.rawValue, rowType: XLFormRowDescriptorTypePassword, title: Tags.Password.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.required = true
        row.value = model.passWord
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.Phone.rawValue, rowType: XLFormRowDescriptorTypePhone, title: Tags.Phone.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["textField.font"] = fontValue
        row.cellConfig["textField.textColor"] = colorLabel
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.cellConfig["textField.enabled"] = false
        row.value = model.phoneNumber
        section.addFormRow(row)

        section.footerTitle = "You'll be notified when it's your turn to drive, your kids have arrived safely and when other parents are talking to you."

        form.addFormSection(section)

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

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.Logout.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.Logout.rawValue)
        row.cellConfig["textLabel.font"] = fontValue
        row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
        row.cellConfigAtConfigure["backgroundColor"] = colorManager.colorDangerRed
        row.action.formSelector = "logout"
        section.addFormRow(row)

        form.addFormSection(section)

        self.form = form
        self.form.delegate = self
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        var formRow = self.form.formRowAtIndex(indexPath)

        if formRow.tag == Tags.Phone.rawValue {
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
        let canManageCell = self.form.formRowWithTag(Tags.CanManage.rawValue)
        let driverCell = self.form.formRowWithTag(Tags.Driver.rawValue)
        let illBeDrivingCell = self.form.formRowWithTag(Tags.IllBeDrivingNotification.rawValue)

        canManageCell.hidden = condition
        driverCell.hidden = condition
        illBeDrivingCell.hidden = condition

        self.updateFormRow(canManageCell)
        self.updateFormRow(driverCell)
        self.updateFormRow(illBeDrivingCell)
    }
/* DEPRECATED
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var um = UserManager.sharedInstance
        var section = indexPath.section
        var row = indexPath.row
        // optionally show FBLoginButton
        if section == 0 && row == 0 {
            if um.userLoggedIn { return 0 }
            else { return 70 }
        }
        if section == 0 && row == 1 { return 86.0 }
        // optionally show logout
        if section == 4 {
            if um.userLoggedIn { return 75 }
            else { return 0 }
        }
        return 44.0
    }
*/
    
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
/* DEPRECATED
    @IBAction func emailLogoutButtonClick(sender: AnyObject) {
        logout()
    }
*/
    
    @IBAction func imageProfileButtonClick(sender: AnyObject) {
        setStatusBarColorDark()
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
/* DEPRECATED
    @IBAction func roleButtonClicked(sender: AnyObject) {
        let button1 = UIAlertAction(title: RoleTypeMommy, style: .Default) { (alert) in
            self.roleButton.setTitle(RoleTypeMommy, forState: .Normal)
        }
        let button2 = UIAlertAction(title: RoleTypeDaddy, style: .Default) { (alert) in
            self.roleButton.setTitle(RoleTypeDaddy, forState: .Normal)
        }
        let button3 = UIAlertAction(title: RoleTypeChild, style: .Default) { (alert) in
            self.roleButton.setTitle(RoleTypeChild, forState: .Normal)
        }
        let button4 = UIAlertAction(title: RoleTypeCareTaker, style: .Default) { (alert) in
            self.roleButton.setTitle(RoleTypeCareTaker, forState: .Normal)
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
*/
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
        let signupForm = getSignupForm()
        self.updateUser(signupForm!)
    }
/* DEPRECATED
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhoneVerification" {
            var des = segue.destinationViewController as! Phone_VC
            des.memberProfileVC = self
        }
    }
*/
    // MARK: Facebook Login
    // --------------------------------------------------------------------------------------------
/* DEPRECATED
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            self.showAlert("Falied to user FB Signup", messege:error.localizedDescription , cancleTitle: "OK")
        } else if (result.isCancelled) {
            self.showAlert("Falied to user FB Signup", messege:"You cancled login" , cancleTitle: "OK")
        } else {
            if result.grantedPermissions.contains("email") {
                println("success")
                LoadingView.showWithMaskType(.Black)
                dataManager.fbSignin(handleLoginResult)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        logout()
    }
*/
    func logout() {
        UserManager.sharedInstance.logoutUser()

        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainController = appDelegate.window!.rootViewController as! MainStackVC
        mainController.setWelcomeView()
    }
/* DEPRECATED
    func handleLoginResult(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        onMainThread() {
            if success {
                self.doneButtonHandler?(self)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.showAlert("Falied to use FB Signup", messege:errorStr , cancleTitle: "OK")
            }
        }
    }
*/
    
    // MARK: Helper Method
    // --------------------------------------------------------------------------------------------
    
    func updateUser(signupForm: SignupForm) {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateUser(signupForm) { (success, errorStr) in
            if success {
                self.handleUpdateOrCreateUserSuccess()
            } else {
                LoadingView.dismiss()
                self.showAlert("Failed to update", messege:errorStr , cancleTitle: "OK")
            }
        }
    }
    
    func createUser(signupForm: SignupForm) {
        LoadingView.showWithMaskType(.Black)
        dataManager.signup(signupForm) { (success, errorStr) in
            if success {
                self.handleUpdateOrCreateUserSuccess()
            } else {
                onMainThread() {
                    LoadingView.dismiss()
                    self.showAlert("Alert", messege: errorStr, cancleTitle: "OK")
                }
            }
        }
    }
    
    func handleUpdateOrCreateUserSuccess() {
        if self.pickedNewImage {
            self.uploadUserProfileImage()
        } else {
            onMainThread() {
                LoadingView.dismiss()
                self.doneButtonHandler?(self)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func uploadUserProfileImage() {
        if let image = profileImageView.image {
            dataManager.upLoadImage(image, comp: handleUploadImageResult)
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
    
    func getSignupForm() -> SignupForm? {
        let formData = self.form.formValues()
        var signupForm = SignupForm()
        signupForm.passwordConfirm = formData[Tags.Password.rawValue] as! String
        signupForm.password = formData[Tags.Password.rawValue] as! String
        signupForm.firstName = formData[Tags.FirstName.rawValue] as! String
        signupForm.lastName = formData[Tags.LastName.rawValue] as! String
        signupForm.phoneNum = formData[Tags.Phone.rawValue] as! String
        signupForm.email = formData[Tags.Email.rawValue] as! String
        signupForm.role = formData[Tags.Role.rawValue] as! String
        return signupForm
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
            phoneCell.value = newNumber!
        } else {
            phoneCell.value = self.model.phoneNumber
        }

        self.tableView.reloadData()
    }

}
