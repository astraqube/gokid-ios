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
        setStatusBarColorDark()
        setNavBarColor(colorManager.appGreen)
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
        self.rightButton.enabled = false
    }
    
    func activeRightBarItem() {
        self.rightButton.enabled = true
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func rightNavButtonTapped() {
        userManager.currentCarpoolName = carpoolTitleTextField.text!
        userManager.currentCarpoolKidName = kidsNameTextField.text!
        userManager.currentCarpoolModel.name = carpoolTitleTextField.text!
        var vc = vcWithID("TimeAndDateFormVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func leftNavButtonTapped() {
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
