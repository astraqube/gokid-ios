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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewDidLoad() {
        self.initForm()
        super.viewDidLoad()

        self.setUpNavigationBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.backgroundColor = colorManager.colorEBF7EB
        self.tableView.tintColor = colorManager.color67C18B
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func initForm() {
        // form provisions
    }

    func setUpNavigationBar() {
        self.setStatusBarColorDark()

        self.leftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        self.rightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)
        
        self.rightButton?.enabled = false
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func rightNavButtonTapped() {
        // child implements this
    }
    
}
