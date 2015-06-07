//
//  MainStackVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class MainStackVC: IIViewDeckController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCenterAndLeftViewControllers()
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
        
        var onboardVC = OnboardVC()
        centerVC.pushViewController(onboardVC, animated: false)
        
        self.centerController = centerVC
        self.leftSize = 100
        self.leftController = meneVC
    }
}
