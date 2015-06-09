//
//  MainStackVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MainStackVC: IIViewDeckController {
    
    var rootVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var um = UserManager.sharedInstance
        if um.useFBLogIn {
            DataManager.sharedInstance.fbSignin() { (success, errorStr) in
                if success { self.rootVC = vcWithID("CalendarVC") }
                else { self.rootVC = OnboardVC() }
                self.setCenterAndLeftViewControllers()
            }
        } else {
            rootVC = OnboardVC()
            setCenterAndLeftViewControllers()
        }
    }
    
    func setCenterAndLeftViewControllers() {
        var meneVC = vcWithID("MenuVC") as! MenuVC
        meneVC.mainStack = self
        
        var centerVC = UINavigationController()
        centerVC.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        centerVC.navigationBar.barTintColor = UIColor.blackColor()
        centerVC.navigationBar.tintColor = UIColor.whiteColor()
        centerVC.navigationBar.backgroundColor = UIColor.blackColor()
        centerVC.navigationBarHidden = true
        centerVC.pushViewController(rootVC!, animated: false)
        
        self.centerController = centerVC
        self.leftSize = 100
        self.leftController = meneVC
    }
}



