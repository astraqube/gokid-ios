//
//  LocationInputVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation

class LocationInputVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var locationInputTextField: PaddingTextField!
    @IBOutlet weak var locationInputButton: UIButton!
    @IBOutlet weak var recentTableView: UITableView!
    
    var locationManager = CLLocationManager()
    var boundTextLabel: UILabel?
    var TableCellID = "RecentAddressCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        recentTableView.reloadData()
    }
    
    func setupTableView() {
        recentTableView.dataSource = self
        recentTableView.delegate = self
    }
    
    func setupNavigationBar() {
        setNavBarTitle("Location")
        setNavBarLeftButtonTitle("Cancel", action: "cancleButtonClick")
        setNavBarRightButtonTitle("Done", action: "doneButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func cancleButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func doneButtonClick() {
        if userManager.userLoggedIn && userManager.userHomeAdress == nil && locationInputTextField.text != "" {
            showHomeAdreeAlertView()
        } else {
            navigationController?.popViewControllerAnimated(true)
            boundTextLabel?.text = locationInputTextField.text
        }
    }
    
    @IBAction func currentLocationButtonClick(sender: AnyObject) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func locationInputButtonClick(sender: AnyObject) {
        var vc = vcWithID("PlacePickerVC") as! PlacePickerVC
        vc.locationVC = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func textfieldEditing(sender: UITextField) {
        boundTextLabel?.text = sender.text
    }
    
    // MARK: CLLocationManagerDelegate
    // --------------------------------------------------------------------------------------------
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil && placemarks.count > 0 {
                var pms = placemarks as! [CLPlacemark]
                var pm = pms.last!
                var add1 = NSString(format: "%@", pm.name) as String
                var add2 = self.add2FromPlaceMark(pm)
                var full = add1 + add2
                self.userManager.recentAddressTitles.insert(add1, atIndex: 0)
                self.userManager.recentAddress.insert(add2, atIndex: 0)
                self.userManager.saveUserInfo()
                self.locationInputTextField.text = full
                self.boundTextLabel?.text = full
                self.locationManager.stopUpdatingLocation()
                
            } else {
                println(error.debugDescription)
            }
        }
    }
    
    // MARK: Location String Convertion Method
    // --------------------------------------------------------------------------------------------
    
    func add2FromPlaceMark(pm: CLPlacemark) -> String {
        var add2 = ""
        if let s = pm.thoroughfare       { add2 += " " + s }
        if let s = pm.locality           { add2 += " " + s }
        if let s = pm.administrativeArea { add2 += " " + s }
        if let s = pm.postalCode         { add2 += " " + s }
        if let s = pm.country            { add2 += " " + s }
        if  count(add2) > 0 {
            if Array(add2)[0] == " " {
                add2.removeAtIndex(add2.startIndex)
            }
        }
        return add2
    }
    
    
    
    
    // MARK: TableView DataSource and Delegate
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userManager.recentAddressTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var row = indexPath.row
        var cell = tableView.cellWithID(TableCellID, indexPath) as! RecentAddressCell
        cell.addressTitleLabel.text = userManager.recentAddressTitles[row]
        cell.addressLabel.text = userManager.recentAddress[row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! RecentAddressCell
        var row = indexPath.row
        locationInputTextField.text = userManager.recentAddressTitles[row] + " " + userManager.recentAddress[row]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showHomeAdreeAlertView() {
        var alertView = UIAlertView(title: "Is this your home address?", message: locationInputTextField.text, delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            var address = locationInputTextField.text
            LoadingView.showWithMaskType(.Black)
            dataManager.updateTeamAddress(address, address2: "") { (success, errorStr) in
                LoadingView.dismiss()
                if success {
                    self.userManager.userHomeAdress = address
                } else {
                    self.showAlert("Fail to update address", messege: errorStr, cancleTitle: "OK")
                }
                self.navigationController?.popViewControllerAnimated(true)
                self.boundTextLabel?.text = self.locationInputTextField.text
            }
        } else {
            navigationController?.popViewControllerAnimated(true)
            boundTextLabel?.text = locationInputTextField.text
        }
    }
}









