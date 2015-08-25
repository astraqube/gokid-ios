//
//  LocationInputVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation

class LocationInputVC: BaseVC, XLFormRowDescriptorViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CLLocationManagerDelegate {

    var rowDescriptor: XLFormRowDescriptor!
    
    @IBOutlet weak var locationInputTextField: PaddingTextField!
    @IBOutlet weak var locationInputButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var homeAddress: UILabel!
    @IBOutlet weak var recentTableView: UITableView!
    
    var donePickingWithAddress: ((String)->())?
    var locationManager = CLLocationManager()
    var TableCellID = "RecentAddressCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        recentTableView.reloadData()
        self.toggleHomeButton()

        if self.rowDescriptor != nil && self.rowDescriptor.title != "" {
            self.titleLabel.text = self.rowDescriptor.title
        }
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }

    func toggleHomeButton() {
        if userManager.userHomeAdress != "" {
            self.homeButton.hidden = false
            self.homeButton.enabled = true
            self.homeAddress.text = userManager.userHomeAdress
        } else {
            self.homeButton.hidden = true
            self.homeButton.enabled = false
            self.homeAddress.text = nil
        }
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------

    func chooseAddressDone(addressTitle: String, address: String) {
        self.askToSaveAsHomeAddress(addressTitle, address2: address) {
            var addressString: String!

            if addressTitle != "Home" {
                self.userManager.addToRecentAddresses(addressTitle, address: address)
                if address.rangeOfString(addressTitle) != nil {
                    addressString = address
                } else {
                    addressString = "\(addressTitle), \(address)"
                }
            } else {
                addressString = address
            }

            if self.rowDescriptor != nil {
                self.rowDescriptor.value = addressString
            } else {
                self.donePickingWithAddress?(addressString)
            }

            self.navigationController?.popViewControllerAnimated(true)
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
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func homeButtonClick(sender: AnyObject) {
        self.chooseAddressDone("Home", address: userManager.userHomeAdress)
    }

    // MARK: CLLocationManagerDelegate
    // --------------------------------------------------------------------------------------------
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.locationManager.stopUpdatingLocation()
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil && placemarks.count > 0 {
                var pms = placemarks as! [CLPlacemark]
                var pm = pms.last!
                let addressTitle = NSString(format: "%@", pm.name) as String
                let address = self.add2FromPlaceMark(pm)
                self.chooseAddressDone(addressTitle, address: address)
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
        self.chooseAddressDone(userManager.recentAddressTitles[row], address: userManager.recentAddress[row])
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    // MARK: Alert View
    // --------------------------------------------------------------------------------------------
    
    func askToSaveAsHomeAddress(address1: String, address2: String, completion: () -> Void) {
        if userManager.userHomeAdress == "" {
            let confirmPrompt = UIAlertController(title: "Is this your Home address?", message: "\(address1), \(address2)", preferredStyle: .Alert)

            confirmPrompt.addAction(UIAlertAction(title: "No", style: .Cancel) { (alert: UIAlertAction!) -> Void in
                completion()
            })

            confirmPrompt.addAction(UIAlertAction(title: "Yes", style: .Default) { (alert: UIAlertAction!) in
                self.dataManager.updateTeamAddress(address1, address2: address2) { (success, errorStr) in
                    completion()
                }
            })

            presentViewController(confirmPrompt, animated: true, completion: nil)

        } else {
            completion()
        }
    }

}
