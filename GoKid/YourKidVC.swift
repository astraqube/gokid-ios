//
//  YourKidVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class YourKidVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your Kid")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var vc = vcWithID("")
        navigationController?.pushViewController(vc, animated: true)
    }
}
