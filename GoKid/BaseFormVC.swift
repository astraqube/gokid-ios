//
//  BaseFormVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class BaseFormVC: XLFormViewController {
    
    var dataManager = DataManager.sharedInstance
    var userManager = UserManager.sharedInstance
    var colorManager = ColorManager.sharedInstance
    var imageManager = ImageManager.sharedInstance
    
    override func viewDidLoad() {
        self.initForm()
        super.viewDidLoad()

        self.setUpNavigationBar()
        self.tableView.backgroundColor = colorManager.colorEBF7EB
        self.view.tintColor = colorManager.color67C18B
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    func initForm() {
        // form provisions
    }

    func setUpNavigationBar() {
        var nav = navigationController as! ZGNavVC
        nav.addTitleViewToViewController(self)
        self.title = "Date & Time"
        self.subtitle = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
        self.setStatusBarColorDark()
        self.setNavBarColor(colorManager.colorEBF7EB)
        self.setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        self.setNavBarRightButtonTitle("Next", action: "nextButtonClick")

        self.navigationItem.rightBarButtonItem?.enabled = false
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        // child implements this
    }
    
}
