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
    
    @IBOutlet weak var calendarIconButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var listIconButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var myDrivesIconButton: UIButton!
    @IBOutlet weak var myDrivesButton: UIButton!
    @IBOutlet weak var settingsIconButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    lazy var allButtons : [UIButton] = {
        return [self.calendarIconButton,self.calendarButton,self.listIconButton,self.listButton,self.myDrivesIconButton,self.myDrivesButton,self.settingsIconButton,self.settingsButton]
    }()
    
    var mainStack: UIViewController?
    var navVC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification()
        setupSubViews()
        navVC = viewDeckController.centerController as? UINavigationController
        
        if (navVC?.topViewController is CalendarVC) {
            selectButtons(allButtons, select: [calendarIconButton, calendarButton])   
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    func registerForNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName("SignupFinished", object: nil, queue: nil) { (noti) in
            self.nameLabel.setTitle(self.userManager.info.firstName, forState: .Normal)
            self.profileImageView.image = self.userManager.userProfileImage
        }
    }
    
    func setupSubViews() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0
        self.profileImageView.clipsToBounds = true
    }
    
    func refreshUI() {
        nameLabel.setTitle(userManager.info.firstName.captialName(), forState: .Normal)
        teamLabel.text = "Team " + userManager.info.lastName.captialName()
        if userManager.info.firstName == "" {
            nameLabel.setTitle("Unknown", forState: .Normal)
        }
        ImageManager.sharedInstance.setImageToView(profileImageView, urlStr: userManager.info.thumURL)
    }
    
    func selectButtons(allButtons : [UIButton], select : [UIButton]) {
        for button in allButtons {
            button.selected = false
        }
        for button in select {
            button.selected = true
        }
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
    
    @IBAction func listButtonClicked(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        var shown = false
        if var carpoolListVC = navVC?.topViewController as? CarpoolListVC {
            shown = true
        }
        if !shown {
            var vc = vcWithID("CarpoolListVC")
            navVC?.setViewControllers([vc], animated: true)
        }
        selectButtons(allButtons, select: [listIconButton, listButton])
    }

    @IBAction func calendarButtonClick(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        var shown = false
        if var calendarVC = navVC?.topViewController as? CalendarVC {
            if calendarVC.onlyShowOurDrives == false {
                shown = true
            }
        }
        if !shown {
            var vc = vcWithID("CalendarVC")
            navVC?.setViewControllers([vc], animated: true)
        }
        selectButtons(allButtons, select: [calendarIconButton, calendarButton])
    }
    
    @IBAction func myDrivesClicked(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        var shown = false
        if var calendarVC = navVC?.topViewController as? CalendarVC {
            if calendarVC.onlyShowOurDrives == true {
                shown = true
            }
        }
        if !shown {
            var vc = vcWithID("CalendarVC") as! CalendarVC
            vc.onlyShowOurDrives = true
            navVC?.setViewControllers([vc], animated: true)
        }
        selectButtons(allButtons, select: [myDrivesIconButton, myDrivesButton])
    }
    
    @IBAction func accountSettingClicked(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        if !(navVC?.topViewController is TeamAccountVC) {
            var vc = vcWithID("TeamAccountVC")
            navVC?.setViewControllers([vc], animated: true)
        }
        selectButtons(allButtons, select: [settingsIconButton, settingsButton])
    }
    
    @IBAction func createCarpoolButtonClick(sender: AnyObject) {
        viewDeckController.toggleLeftView()
        var vc = vcWithID("BasicInfoVC")
        navVC?.pushViewController(vc, animated: true)
    }
}
