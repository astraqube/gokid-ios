//
//  BasicInfoVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class BasicInfoVC: BaseVC {
    
    @IBOutlet weak var carpoolTitleTextField: PaddingTextField!
    @IBOutlet weak var kidsNameTextField: PaddingTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavigationBar() {
        setNavBarTitle("Basic Info")
        setNavBarLeftButtonTitle("Do this later", action: "doLaterButtonClick")
        disableRightBarItem()
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Disable and Active Nav Right Button
    // --------------------------------------------------------------------------------------------
    
    func disableRightBarItem() {
        var rightButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: nil)
        rightButton.tintColor = colorManager.disableColor
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func activeRightBarItem() {
        var rightButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextButtonClick")
        rightButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func nextButtonClick() {
        var vc = vcWithID("TimeAndDateVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func doLaterButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func carpoolTitleChanged(sender: AnyObject) {
        checkRightBarItemAvalebility()
    }
    
    @IBAction func kidsNameChanged(sender: AnyObject) {
        checkRightBarItemAvalebility()
    }
    
    // MARK: Helper Methos
    // --------------------------------------------------------------------------------------------
    
    func checkRightBarItemAvalebility() {
        var s1 = carpoolTitleTextField.text
        var s2 = kidsNameTextField.text
        if count(s1) > 0 && count(s2) > 0 {
            activeRightBarItem()
        } else {
            disableRightBarItem()
        }
    }
}
