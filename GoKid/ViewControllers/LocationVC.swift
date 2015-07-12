//
//  LocationVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class LocationVC: BaseVC {

    @IBOutlet weak var destinationLocationLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var destLocationButton: UIButton!
    @IBOutlet weak var startLocationButton: UIButton!
    @IBOutlet weak var navSubtitleLabel: UILabel!
    @IBOutlet weak var switchBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupSubview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpNavigationBar() {
        navSubtitleLabel.text = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
    }
    
    func setupSubview() {
        switchBackgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
        switchBackgroundView.layer.borderWidth = 2.0
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        if userManager.currentCarpoolModel.isValidForLocation() {
            var vc = vcWithID("VolunteerVC")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert("Alert", messege: "Please fill in all locations", cancleTitle: "OK")
        }
    }
    
    @IBAction func startLocationButtonClick(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.donePickingWithAddress = donePickingStartLocationWithAddress
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func destinationLocationButtonClick(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.donePickingWithAddress = donePickingEndLocationWithAddress
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func donePickingStartLocationWithAddress(address: String) {
        self.startLocationLabel.text = address
        userManager.currentCarpoolModel.startLocation = address
    }
    
    func donePickingEndLocationWithAddress(address: String) {
        self.destinationLocationLabel.text = address
        userManager.currentCarpoolModel.endLocation = address
    }
}
