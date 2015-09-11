//
//  YourKidVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/5/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class YourKidVC: BaseVC {

    var invitation: InvitationModel!

    @IBOutlet weak var kidsNameTextField: PaddingTextField!
    @IBOutlet weak var carpoolNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var kidNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setStatusBarColorDark()
        carpoolNameLabel.text = carpoolNameLabel.text?.replace("XXX", invitation.carpool.name)
        kidNameLabel.text = kidNameLabel.text?.replace("XXX", invitation.rider.firstName)
        kidsNameTextField.keyboardType = .NamePhonePad
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        if kidsNameTextField.text == "" {
            showAlert("Alert", messege: "Please provide your kid's name", cancleTitle: "OK")
            return
        }
        
        LoadingView.showWithMaskType(.Black)
        dataManager.addKidsNameToCarpool(invitation.carpool.id, name: kidsNameTextField.text) { (success, errStr, riderObj) in
            LoadingView.dismiss()
            if success {
                self.moveToConfirmTimes(riderObj as! RiderModel)
            } else {
                self.showAlert("Failed to add your kid's name", messege: errStr, cancleTitle: "OK")
            }
        }
    }

    func moveToConfirmTimes(rider: RiderModel) {
        dataManager.getOccurenceOfCarpool(invitation.carpool.id, rider: rider) { (success, error) in
            if success {
                var vc = vcWithID("InviteConfirmTimesVC") as! InviteConfirmTimesVC
                vc.rider = rider
                vc.invitation = self.invitation
                vc.occurrences = self.userManager.volunteerEvents
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Failed to load carpool times", messege: error, cancleTitle: "OK")
            }
        }
    }

}
