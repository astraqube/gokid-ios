//
//  PlacePickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/24/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class PlacePickerVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [GMSAutocompletePrediction]()
    var teamVC : TeamAccountVC?
    var locationVC : LocationInputVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func searchPlacesAndReloadTable(input: String) {
        
        let menlo = CLLocationCoordinate2DMake(37.4528, 122.1833)
        let northEast = CLLocationCoordinate2DMake(menlo.latitude + 1, menlo.longitude + 1)
        let southWest = CLLocationCoordinate2DMake(menlo.latitude - 1, menlo.longitude - 1)
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
    
    // MARK: TableView DataSource and Delegate
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
    
    @IBAction func doneButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var prediction = dataSource[indexPath.row]
        var description = descriptionFromPrediction(prediction)
        var fullAddress = description.title + ", " + description.subtitle
 
        userManager.recentAddressTitles.append(description.title)
        userManager.recentAddress.append(description.subtitle)
        teamVC?.setHomeAddress(description.title, address2: description.subtitle)
        locationVC?.locationInputTextField.text = fullAddress
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
    
}
