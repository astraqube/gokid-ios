//
//  MenuVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MenuVC: BaseVC {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UIButton!
    @IBOutlet weak var teamLabel: UILabel!
    
    var mainStack: UIViewController?
    var navVC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification()
        setupSubViews()
        navVC = viewDeckController.centerController as? UINavigationController
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshUI()
    }
    
    func registerForNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName("SignupFinished", object: nil, queue: nil) { (noti) in
            self.nameLabel.setTitle(self.userManager.info.firstName, forState: .Normal)
            self.profileImageView.image = self.userManager.userProfileImage
        }
    }
    
    func setupSubViews() {
        self.view.backgroundColor = UIColor.blackColor()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0
        self.profileImageView.clipsToBounds = true
    }
    
    func refreshUI() {
        nameLabel.setTitle(userManager.info.firstName, forState: .Normal)
        teamLabel.text = userManager.userTeamName
        if userManager.info.firstName == "" {
            nameLabel.setTitle("Unknown", forState: .Normal)
        }
        ImageManager.sharedInstance.setImageToView(profileImageView, urlStr: userManager.info.thumURL)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func nameButtonClicked(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        if !(navVC?.topViewController is TeamAccountVC) {
            var vc = vcWithID("TeamAccountVC")
            navVC?.setViewControllers([vc], animated: true)
        }
    }
    
    @IBAction func accountSettingClicked(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        if !(navVC?.topViewController is TeamAccountVC) {
            var vc = vcWithID("TeamAccountVC")
            navVC?.setViewControllers([vc], animated: true)
        }
    }
    
    @IBAction func calendarButtonClick(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        if !(navVC?.topViewController is CalendarVC) {
            var vc = vcWithID("CalendarVC")
            navVC?.setViewControllers([vc], animated: true)
        }
    }
    
    @IBAction func createCarpoolButtonClick(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        var vc = vcWithID("BasicInfoVC")
        navVC?.pushViewController(vc, animated: true)
    }
}
