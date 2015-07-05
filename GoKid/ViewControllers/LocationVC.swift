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
        var nav = navigationController as! ZGNavVC
        nav.addTitleViewToViewController(self)
        self.title = "Location"
        self.subtitle = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
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
        if userManager.currentCarpoolModel.isValidForLocation() {
            startCarpoolCreation()
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
    
    // MARK: NetWork Carpool Creation
    // --------------------------------------------------------------------------------------------
    
    func startCarpoolCreation() {
        LoadingView.showWithMaskType(.Black)
        if userManager.userLoggedIn {
            dataManager.createCarpool(userManager.currentCarpoolModel, comp: handleCreateCarpool)
        } else {
            dataManager.getFakeVolunteerList(userManager.currentCarpoolModel, comp: handleGetFakeVolunteerList)
        }
    }
    
    func handleCreateCarpool(success: Bool, errorStr: String) {
        if success {
            dataManager.getOccurenceOfCarpool(userManager.currentCarpoolModel.id, comp: handleGetVolunteerList)
        } else {
            LoadingView.dismiss()
            self.showAlert("Fail to create carpool", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func handleGetVolunteerList(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            moveToVolunteerVC()
        } else {
            self.showAlert("Fail to fetch vlounteer list", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func handleGetFakeVolunteerList(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            moveToVolunteerVC()
        } else {
            self.showAlert("Fail to fecth unregistered volunteer list", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func moveToVolunteerVC() {
        onMainThread() {
            var vc = vcWithID("VolunteerVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
