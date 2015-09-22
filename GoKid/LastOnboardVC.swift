//
//  LastOnboardVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class LastOnboardVC: BaseVC {

    @IBOutlet weak var joinNowButton: UIButton!
    var goNowButtonHandler: (()->())?
    var joinNowButtonHandler: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinNowButton.layer.cornerRadius = 2.0
        joinNowButton.layer.borderWidth = 2.0
        joinNowButton.layer.borderColor = rgb(89,g: 183,b: 123).CGColor
    }
    
    @IBAction func goNowButtonTapped(sender: AnyObject) {
        goNowButtonHandler?()
    }
    
    @IBAction func joinNowButtonTapped(sender: AnyObject) {
        joinNowButtonHandler?()
    }
}
