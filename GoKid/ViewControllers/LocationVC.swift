//
//  LocationVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import MapKit

class LocationVC: BaseVC {
    
    @IBOutlet weak var switchBackgroundView: UIView!
    @IBOutlet weak var taponLabel: UILabel!
    @IBOutlet weak var segmentControl: GKSegmentControl!
    typealias GeoCompltion = ((CLLocationDegrees, CLLocationDegrees)->())
    
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
    
    var originDestSame = true
    var heightRatio: CGFloat = 0.40
    var dataSource = [(OccurenceModel, OccurenceModel)]() // drop pick
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setupSubviews()
        relayout()
        tryRefreshUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpNavigationBar() {
        subtitleLabel?.text = userManager.currentCarpoolDescription()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        //if userManager.currentCarpoolModel.isValidForLocation() {
            var vc = vcWithID("VolunteerVC")
            navigationController?.pushViewController(vc, animated: true)
        //} else {
        //    showAlert("Alert", messege: "Please fill in all locations", cancleTitle: "OK")
        //}
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
        originDestSame = (sender.on == true)
        relayout()
        
        var i = segmentControl.selectedSegmentIndex
        if originDestSame {
            dataSource[i].1.poolLocation = dataSource[i].0.poolLocation
        }
        syncLocalEventsWithSever()
        updateEventViewOnMainThread()
    }
    
    @IBAction func segmentControlTapped(sender: UISegmentedControl) {
        var i = sender.selectedSegmentIndex
        updateEventViewOnMainThread()
    }
    
    func donePickingStartLocationWithAddress(address: String) {
        geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var location = Location(name: address, long: long, lati: lati)
            self.dataSource[i].0.poolLocation = location.makeCopy()
            if self.originDestSame {
                self.dataSource[i].1.poolLocation = location.makeCopy()
            }
            self.updateEventViewOnMainThread()
            self.syncLocalEventsWithSever()
        }
    }
    
    func donePickingEndLocationWithAddress(address: String) {
        geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var location = Location(name: address, long: long, lati: lati)
            self.dataSource[i].1.poolLocation = location.makeCopy()
            self.updateEventViewOnMainThread()
            self.syncLocalEventsWithSever()
        }
    }
    
    // MARK: Network Fetch
    // --------------------------------------------------------------------------------------------
    
    func tryRefreshUI() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getOccurenceOfCarpool(userManager.currentCarpoolModel.id) { success, errStr in
            onMainThread() {
                LoadingView.dismiss()
                self.handleGetOccurenceOfCarpool(success, errStr)
            }
        }
    }
    
    func handleGetOccurenceOfCarpool(success: Bool, _ errStr: String) {
        if success {
            dataSource = userManager.groupedVolunteerEvents()
            displayWithDataSource()
        } else {
            showAlert("Fail to fetch carpools", messege: errStr, cancleTitle: "OK")
        }
    }
    
    func displayWithDataSource() {
        if dataSource.count <= 1 {
            segmentControl.alpha = 0.0
            segmentControl.userInteractionEnabled = false
        } else {
            segmentControl.removeAllSegments()
            for (i, data) in enumerate(dataSource) {
                var title = data.0.occursAt?.weekDayString()
                segmentControl.insertSegmentWithTitle(title, atIndex: i, animated: false)
            }
        }
        segmentControl.selectedSegmentIndex = 0
        updateEventViewOnMainThread()
    }
    
    func syncLocalEventsWithSever() {
        var i = segmentControl.selectedSegmentIndex
        var drop = dataSource[i].0
        var pick = dataSource[i].1
        
        LoadingView.showWithMaskType(.Black)
        dataManager.updateOccurenceLocation(drop) { (success, errStr) in }
        dataManager.updateOccurenceLocation(pick, comp: handleUpdateLocation)
    }
    
    func handleUpdateLocation(success: Bool, errStr: String) {
        onMainThread() {
            LoadingView.dismiss()
            if !success {
                self.showAlert("Fail to update location", messege: errStr, cancleTitle: "OK")
            }
        }
    }
    
    func updateEventViewOnMainThread() {
        var i = segmentControl.selectedSegmentIndex
        onMainThread() {
            self.startLocationLabel.text = self.dataSource[i].0.poolLocation.name
            self.destinationLocationLabel.text = self.dataSource[i].1.poolLocation.name
        }
    }
    
    func geoCodeAddress(address: String, comp: GeoCompltion) {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (obj, err)  in
            println(obj)
            if let pms = obj as? [CLPlacemark] {
                println(pms.count)
                if pms.count >= 1 {
                    var coor = pms[0].location.coordinate
                    comp(coor.longitude, coor.latitude)
                    return
                }
            }
            self.showAlert("Cannot geocode address", messege: address, cancleTitle: "OK")
        }
    }
}



