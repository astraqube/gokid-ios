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
    
    var largeLeftButton: UIButton?
    var largeRightButton: UIButton?
    
    override func viewDidLoad() {
        self.initForm()
        super.viewDidLoad()
        addLargeNavigationButton()
    }
    
    func addLargeNavigationButton() {
        var buttonW: CGFloat = 40
        var buttonH: CGFloat = 36
        var windowW = userManager.windowW
        largeLeftButton = UIButton(frame: CGRectMake(0.0, 20.0, buttonW, buttonH))
        largeRightButton = UIButton(frame: CGRectMake(windowW-buttonW, 20.0, buttonW, buttonH))
        largeLeftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        largeRightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)
        if leftButton != nil {
            view.insertSubview(largeLeftButton!, belowSubview: leftButton)
        }
        if rightButton != nil {
            view.insertSubview(largeRightButton!, belowSubview: rightButton)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpNavigationBar()

        self.tableView.backgroundColor = colorManager.colorEBF7EB
        self.tableView.tintColor = colorManager.color67C18B
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        self.toggleRightNavButtonState()
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

        // For the actual navbar
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = colorManager.colorEBF7EB
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 20)!, NSForegroundColorAttributeName: colorManager.color507573 ]

        let backButton = UIBarButtonItem(image: UIImage(named: "map_back-arrow"), style: .Plain, target: self, action: "leftNavButtonTapped")
        navigationItem.leftBarButtonItem = backButton

        // For the hand-made navbar
        self.leftButton?.addTarget(self, action: "leftNavButtonTapped", forControlEvents: .TouchUpInside)
        self.rightButton?.addTarget(self, action: "rightNavButtonTapped", forControlEvents: .TouchUpInside)
    }

    func toggleRightNavButtonState() {
        // enable or disable the next button
        self.rightButton?.enabled = self.formValidationErrors().isEmpty
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
