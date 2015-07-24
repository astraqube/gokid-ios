//
//  YourKidVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class YourKidVC: BaseVC {

    @IBOutlet weak var kidsNameTextField: PaddingTextField!
    @IBOutlet weak var carpoolNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var kidNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your Kid")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        carpoolNameLabel.text = carpoolNameLabel.text?.replace("XXX", userManager.currentCarpoolModel.name)
        kidNameLabel.text = kidNameLabel.text?.replace("XXX", userManager.inviteKidName)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        if kidsNameTextField.text == "" {
            showAlert("Alert", messege: "Please fiil yout kid's name", cancleTitle: "OK")
            return
        }
        
        var carpoolID = userManager.currentCarpoolModel.id
        LoadingView.showWithMaskType(.Black)
        dataManager.addKidsNameToCarpool(carpoolID, name: kidsNameTextField.text) { (success, errStr) in
            LoadingView.dismiss()
            if success {
                self.moveToVolunteerVC()
            } else {
                self.showAlert("Fail to add kids name", messege: errStr, cancleTitle: "OK")
            }
        }
    }
    
    func moveToVolunteerVC() {
        onMainThread() {
            var vc = vcWithID("VolunteerVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
