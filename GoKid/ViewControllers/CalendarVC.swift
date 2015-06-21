//
//  CalendarVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CalendarVC: BaseVC {

    @IBOutlet weak var borderImageView: UIImageView!
    @IBOutlet weak var tableView: UIImageView!
    var dataSource = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("GoKids")
        setNavBarLeftButtonTitle("Menu", action: "menuButtonClick")
        setNavBarRightButtonTitle("Create", action: "createButtonClicked")
    }
    
    func setupSubviews() {
        self.borderImageView.layer.borderColor = UIColor.blackColor().CGColor
        self.borderImageView.layer.borderWidth = 3.0
        self.borderImageView.layer.opacity = 0.5
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func createButtonClicked() {
        var vc = vcWithID("BasicInfoVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func menuButtonClick() {
        self.navigationController?.viewDeckController.toggleLeftViewAnimated(true)
    }
    
    // MARK: TableView DataSource and Delegate
    // --------------------------------------------------------------------------------------------
    
    
}
