//
//  FrequencyPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class FrequencyPickerVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupNavBar() {
        setNavBarTitle("Repeat")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Done", action: "nextButtonClick")
    }
    
    // MARK: IBAction Methods
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        println("next button click")
    }
}
