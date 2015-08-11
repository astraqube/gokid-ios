//
//  PlacePickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/24/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation

class PlacePickerVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [GMSAutocompletePrediction]()
    var teamVC : TeamAccountVC?
    var locationVC : LocationInputVC?
    var proximity: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.4528, 122.1833)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProximity()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchTextField.becomeFirstResponder()
    }
    
    func setupTableView() {
        // Empty table treatment
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
    }

    func setupProximity() {
        let placesClient = GMSPlacesClient()
        placesClient.currentPlaceWithCallback { (places: GMSPlaceLikelihoodList?, error: NSError?) in
            if error == nil && places != nil {
                let location = places!.likelihoods[0] as! GMSPlaceLikelihood
                self.proximity = location.place.coordinate
            }r
        }
    }

    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var prediction = dataSource[indexPath.row]
        var cell = tableView.cellWithID("PlaceResultCell", indexPath) as! PlaceResultCell
        var description = descriptionFromPrediction(prediction)
        cell.titleLabel.text = description.title
        cell.subtitleLabel.text = description.subtitle
        return cell
    }
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var prediction = dataSource[indexPath.row]
        var description = descriptionFromPrediction(prediction)

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
        var searchText = searchTextField.text
        if count(searchText) > 0 {
            searchPlacesAndReloadTable(searchText)
        } else {
            dataSource = [GMSAutocompletePrediction]()
            tableView.reloadData()
        }
    }
    
    // MARK: Search Method
    // --------------------------------------------------------------------------------------------
    
    func searchPlacesAndReloadTable(input: String) {
        // MARK: TODO Change the place?
        let northEast = CLLocationCoordinate2DMake(proximity.latitude + 1, proximity.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(proximity.latitude - 1, proximity.longitude - 1)
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        
        var placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(input, bounds: bounds, filter: filter, callback: { (results, error) in
            if error != nil {
                println("Autocomplete error \(error) for query '\(input)'")
                return
            }
            println(results)
            self.dataSource = [GMSAutocompletePrediction]()
            if let predictions = results as? [GMSAutocompletePrediction] {
                for result in predictions {
                    self.dataSource.append(result)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func descriptionFromPrediction(prediction: GMSAutocompletePrediction) -> (title: String, subtitle: String) {
        var names = prediction.attributedFullText.string.componentsSeparatedByString(", ")
        var title = names[0]
        names.removeAtIndex(0)
        var subtitle = ""
        for i in 0..<names.count {
            subtitle += names[i]
            if i != names.count-1 {
                subtitle += ", "
            }
        }
        return (title, subtitle)
    }
    
}
