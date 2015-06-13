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
    }
    
    func setupTableView() {
        recentTableView.dataSource = self
        recentTableView.delegate = self
    }
    
    func setupNavigationBar() {
        setNavBarTitle("Location")
        setNavBarLeftButtonTitle("Cancle", action: "cancleButtonClick")
        setNavBarRightButtonTitle("Done", action: "doneButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func cancleButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func doneButtonClick() {
        if userManager.userHomeAdress == nil && locationInputTextField.text != "" {
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
                // println(pm.subThoroughfare)
                // println(pm.thoroughfare)
                var str = NSString(format: "%@ %@ %@ %@", pm.postalCode, pm.locality, pm.administrativeArea, pm.country) as String
                self.locationInputTextField.text = str
                self.boundTextLabel?.text = str
                self.locationManager.stopUpdatingLocation()
                
            } else {
                println(error.debugDescription)
            }
        }
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
        locationInputTextField.text = cell.addressLabel.text
    }
    
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func showHomeAdreeAlertView() {
        var alertView = UIAlertView(title: "Is this your home address?", message: locationInputTextField.text, delegate: self, cancelButtonTitle: "Yes", otherButtonTitles: "No")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            userManager.userHomeAdress = locationInputTextField.text
        }
        navigationController?.popViewControllerAnimated(true)
        boundTextLabel?.text = locationInputTextField.text
    }
}









