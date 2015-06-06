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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpButtonApperence()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setUpNavigationBar() {
        setNavBarTitle("Location")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    func setUpButtonApperence() {
        var w: CGFloat = 5.0
        destLocationButton.layer.cornerRadius = destLocationButton.w/2.0
        destLocationButton.layer.borderColor = colorManager.blueColor.CGColor
        destLocationButton.layer.borderWidth = w
        startLocationButton.layer.cornerRadius = startLocationButton.w/2.0
        startLocationButton.layer.borderColor = colorManager.blueColor.CGColor
        startLocationButton.layer.borderWidth = w
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var vc = vcWithID("VolunteerVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func startLocationButtonClick(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.boundTextLabel = startLocationLabel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func destinationLocationButtonClick(sender: AnyObject) {
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.boundTextLabel = destinationLocationLabel
        navigationController?.pushViewController(vc, animated: true)
    }
}
