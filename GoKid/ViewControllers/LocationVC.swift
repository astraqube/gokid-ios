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

    var carpool: CarpoolModel!
    var rider: RiderModel!

    @IBOutlet weak var switchBackgroundView: UIView!
    @IBOutlet weak var taponLabel: UILabel!
    @IBOutlet weak var segmentControl: GKSegmentControl!
    
    var destLocationButton: UIButton!
    var startLocationButton: UIButton!
    var eventButton: UIButton!
    
    var destinationLocationLabel: UILabel!
    var startLocationLabel: UILabel!
    var eventLocationLabel: UILabel!
    
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
        subtitleLabel?.text = "\(carpool.name) for \(rider.firstName)"
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func rightNavButtonTapped() {
        syncLocalEventsWithSever()
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
        var vc = vcWithID("LocationInputVC") as! LocationInputVC
        vc.donePickingWithAddress = donePickingEventLocationWithAddress
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func OriginDestinationSame(sender: UISwitch) {
        originDestSame = (sender.on == true)
        relayout()
        
        var i = segmentControl.selectedSegmentIndex
        if originDestSame {
            dataSource[i].1.defaultLocation = dataSource[i].0.defaultLocation
        }
        updateEventViewOnMainThread()
    }
    
    @IBAction func segmentControlTapped(sender: UISegmentedControl) {
        var i = sender.selectedSegmentIndex
        updateEventViewOnMainThread()
    }
    
    func donePickingStartLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var location = Location(name: address, long: long, lati: lati)
            self.dataSource[i].0.defaultLocation = location.makeCopy()
            if self.originDestSame {
                self.dataSource[i].1.defaultLocation = location.makeCopy()
            }
            self.updateEventViewOnMainThread()
        }
    }
    
    func donePickingEndLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var location = Location(name: address, long: long, lati: lati)
            self.dataSource[i].1.defaultLocation = location.makeCopy()
            self.updateEventViewOnMainThread()
        }
    }
    
    func donePickingEventLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var location = Location(name: address, long: long, lati: lati)
            self.dataSource[i].0.eventLocation = location.makeCopy()
            self.dataSource[i].1.eventLocation = location.makeCopy()
            self.updateEventViewOnMainThread()
        }
    }
    
    // MARK: Network Fetch
    // --------------------------------------------------------------------------------------------
    
    func tryRefreshUI() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getOccurenceOfCarpool(carpool.id, rider: rider) { success, errStr in
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
        LoadingView.showWithMaskType(.Black)
        dataManager.updateOccurencesLocation(dataSource) { success, errStr in
            onMainThread() {
                LoadingView.dismiss()
                if success {
                    var vc = vcWithID("VolunteerVC") as! VolunteerVC
                    vc.carpool = self.carpool
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert("Fail to update location", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }
    
    func updateEventViewOnMainThread() {
        var i = segmentControl.selectedSegmentIndex
        onMainThread() {
            self.startLocationLabel.text = self.dataSource[i].0.defaultLocation.name
            self.destinationLocationLabel.text = self.dataSource[i].1.defaultLocation.name
            self.eventLocationLabel.text = self.dataSource[i].0.eventLocation.name
        }
    }
    
}
