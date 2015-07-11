//
//  MemberProfileVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MemberProfileVC: BaseTVC, FBSDKLoginButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var emailLogoutButton: UIButton!
    @IBOutlet weak var fblogoutButton: FBSDKLoginButton!
    @IBOutlet weak var fbloginButton: FBSDKLoginButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: PaddingTextField!
    @IBOutlet weak var roleButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var doneButtonHandler: ((MemberProfileVC)->())?
    var sourceCellType: TeamCellType = .None
    var sourceCellIndex: Int = 0
    var model = TeamMemberModel()
    var pickedNewImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupLoginButton()
        setUpLogoutButton()
        refreshUIIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your profile")
        setNavBarRightButtonTitle("Save", action: "saveButtonClick")
    }
    
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
    
    @IBAction func emailLogoutButtonClick(sender: AnyObject) {
        logout()
    }
    
    
    @IBAction func imageProfileButtonClick(sender: AnyObject) {
        setStatusBarColorDark()
        var picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
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
    
    func saveButtonClick() {
        var um = UserManager.sharedInstance
        if let signupForm = getSignupForm() {
            if um.userLoggedIn { updateUser(signupForm) }
            else { createUser(signupForm) }
        } else {
            showAlert("Alert", messege: "Please Fill in all Blank", cancleTitle: "OK")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PhoneVerification" {
            var des = segue.destinationViewController as! Phone_VC
            des.memberProfileVC = self
        }
    }
    
    // MARK: Facebook Login
    // --------------------------------------------------------------------------------------------
    
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
    
    func logout() {
        var um = UserManager.sharedInstance
        um.userLoggedIn = false
        um.userToken = ""
        um.useFBLogIn = false
        um.userFirstTimeLogin = true
        um.info = TeamMemberModel()
        um.saveUserInfo()
        
        var vc = OnboardVC()
        navigationController?.setViewControllers([vc], animated: true)
    }
    
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

    
    // MARK: Helper Method
    // --------------------------------------------------------------------------------------------
    
    func updateUser(signupForm: SignupForm) {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateUser(signupForm) { (success, errorStr) in
            if success {
                self.handleUpdateOrCreateUserSuccess()
            } else {
                LoadingView.dismiss()
                self.showAlert("Falied to use FB Signup", messege:errorStr , cancleTitle: "OK")
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
        if let password = passwordTextField.text,
            firstName = firstNameTextField.text,
            lastName = lastNameTextField.text,
            email = emailTextField.text,
            role = roleButton.titleLabel?.text?.lowercaseString,
            phoneNum = phoneNumberTextField.text
        {
            var signupForm = SignupForm()
            signupForm.passwordConfirm = password
            signupForm.password = password
            signupForm.firstName = firstName
            signupForm.lastName = lastName
            signupForm.phoneNum = phoneNum
            signupForm.email = email
            signupForm.role = role
            return signupForm
        }
        return nil
    }
}
