//
//  PlacePickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/24/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PlacePickerVC: BaseVC, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var dataSource = []
    var teamVC : TeamAccountVC?
    var locationVC : LocationInputVC?
    var proximity: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.4528, 122.1833)
    var locator = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProximity()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchTextField.becomeFirstResponder()
        setStatusBarColorDark()
    }
    
    func setupTableView() {
        // Empty table treatment
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
    }

    func setupProximity() {
        locator.delegate = self
        locator.requestWhenInUseAuthorization()
        locator.startUpdatingLocation()
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debounce(NSTimeInterval(1.5), queue: dispatch_get_main_queue()) {
            let myLocation = locations.last
            self.proximity = myLocation!.coordinate
            self.locator.stopUpdatingLocation()
        }()
    }

    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.cellWithID("PlaceResultCell", indexPath) as! PlaceResultCell

        if let place = self.dataSource.objectAtIndex(indexPath.row) as? MKMapItem {
            let description = descriptionFromPrediction(place)
            cell.titleLabel.text = description.title
            cell.subtitleLabel.text = description.subtitle
        }

        return cell
    }

    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.dataSource.objectAtIndex(indexPath.row) as? MKMapItem
        let description = descriptionFromPrediction(place!)

        self.dismissViewControllerAnimated(true) {
            self.teamVC?.setHomeAddress(description.title, address2: description.subtitle)
            self.locationVC?.chooseAddressDone(description.title, address: description.subtitle)
        }
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func doneButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchChanges(sender: AnyObject) {
        debounce(NSTimeInterval(1.5), queue: dispatch_get_main_queue()) {
            let searchText = self.searchTextField.text
            if searchText?.characters.count > 3 {
                self.searchPlacesAndReloadTable(searchText!)
            } else {
                self.dataSource = []
                self.tableView.reloadData()
            }
        }()
    }
    
    // MARK: Search Method
    // --------------------------------------------------------------------------------------------
    
    func searchPlacesAndReloadTable(query: String) {
        let distance = 1000
        let diameter = CLLocationDistance(distance)
        let region = MKCoordinateRegionMakeWithDistance(self.proximity, diameter, diameter)

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        request.region = region

        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler {
            (response: MKLocalSearchResponse?, error: NSError?) in
            if error == nil {
                self.dataSource = response!.mapItems
            }
            self.tableView.reloadData()
        }
    }

    func descriptionFromPrediction(place: MKMapItem) -> (title: String, subtitle: String) {
        let title = place.name
        var subtitle: String!

        if let _ = place.placemark.subThoroughfare {
            subtitle = String(format: "%@ %@, %@, %@ %@",
                place.placemark.subThoroughfare!,
                place.placemark.thoroughfare!,
                place.placemark.locality!,
                place.placemark.administrativeArea!,
                place.placemark.postalCode!)
        } else {
            subtitle = ""
        }

        return (title!, subtitle)
    }
    
}
