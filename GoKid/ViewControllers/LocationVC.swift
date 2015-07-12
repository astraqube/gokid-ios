//
//  LocationVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class LocationVC: BaseVC {

    @IBOutlet weak var switchBackgroundView: UIView!
    @IBOutlet weak var taponLabel: UILabel!
    
    var destLocationButton: UIButton!
    var startLocationButton: UIButton!
    var eventButton: UIButton!
    
    var destinationLocationLabel: UILabel!
    var startLocationLabel: UILabel!
    
    var startLabel: UILabel!
    var destLabel: UILabel!
    var eventLabel: UILabel!
    
    var doubleArrow: UIImageView!
    var arrow1: UIImageView!
    var arrow2: UIImageView!
    
    var layoutSame = true
    var heightRatio: CGFloat = 0.40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupSubviews()
        relayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpNavigationBar() {
        subtitleLabel?.text = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        if userManager.currentCarpoolModel.isValidForLocation() {
            var vc = vcWithID("VolunteerVC")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert("Alert", messege: "Please fill in all locations", cancleTitle: "OK")
        }
    }
    
    func startLocationButtonTapped(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.donePickingWithAddress = donePickingStartLocationWithAddress
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func destButtonTapped(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.donePickingWithAddress = donePickingEndLocationWithAddress
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func eventButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func OriginDestinationSame(sender: UISwitch) {
        layoutSame = (sender.on == true)
        relayout()
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
