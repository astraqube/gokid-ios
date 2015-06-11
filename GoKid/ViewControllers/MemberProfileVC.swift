//
//  MemberProfileVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MemberProfileVC: UITableViewController {
  
  
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!

  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var teamLabel: UILabel!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var roleButton: UIButton!
  var model = TeamMemberModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    refreshUIIfNeeded()
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


  // MARK: IBAction Method
  // --------------------------------------------------------------------------------------------
  
  @IBAction func removeButtonClick(sender: AnyObject) {
    
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
