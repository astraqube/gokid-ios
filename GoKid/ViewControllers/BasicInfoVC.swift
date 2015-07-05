//
//  BasicInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class BasicInfoVC: BaseVC {
    
    @IBOutlet weak var carpoolTitleTextField: PaddingTextField!
    @IBOutlet weak var kidsNameTextField: PaddingTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupKeyBoardMoveup()
        clenUserCurrentCarPoolData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func setupNavigationBar() {
        setNavBarLeftButtonTitle("Do this later", action: "doLaterButtonClick")
        disableRightBarItem()
    }
  
    func clenUserCurrentCarPoolData() {
        userManager.currentCarpoolModel = CarpoolModel()
    }
    
    func setupKeyBoardMoveup() {
        // iphone 5
        if userManager.windowH < 580 {
            self.keyBoardMoveUp = 82
        }
    }
    
    // MARK: Disable and Active Nav Right Button
    // --------------------------------------------------------------------------------------------
    
    func disableRightBarItem() {
        var rightButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: nil)
        rightButton.tintColor = colorManager.disableColor
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func activeRightBarItem() {
        var rightButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextButtonClick")
        rightButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func nextButtonClick() {
        userManager.currentCarpoolName = carpoolTitleTextField.text!
        userManager.currentCarpoolKidName = kidsNameTextField.text!
        userManager.currentCarpoolModel.name = carpoolTitleTextField.text!
        var vc = vcWithID("TimeAndDateVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func doLaterButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func carpoolTitleChanged(sender: AnyObject) {
        checkRightBarItemAvalebility()
    }
    
    @IBAction func kidsNameChanged(sender: AnyObject) {
        checkRightBarItemAvalebility()
    }
    
    // MARK: Helper Methos
    // --------------------------------------------------------------------------------------------
    
    func checkRightBarItemAvalebility() {
        var s1 = carpoolTitleTextField.text
        var s2 = kidsNameTextField.text
        if count(s1) > 0 && count(s2) > 0 {
            activeRightBarItem()
        } else {
            disableRightBarItem()
        }
    }
}
