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
    var rider: RiderModel?

    @IBOutlet weak var switchBackgroundView: UIView!
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
    var dataSource: [OccurenceModel]!
    var dataSourceCollated: [String: [OccurenceModel]] = Dictionary()

    var currentPickupOccurrence: OccurenceModel?
    var currentDropoffOccurrence: OccurenceModel?

    var hideBackButton = false

    var eventLocation: Location? {
        get {
            if currentPickupOccurrence != nil {
                return currentPickupOccurrence?.eventLocation
            }
            if currentDropoffOccurrence != nil {
                return currentDropoffOccurrence?.eventLocation
            }
            return nil
        }
        set {
            if currentPickupOccurrence != nil {
                currentPickupOccurrence?.eventLocation = newValue!
            }
            if currentDropoffOccurrence != nil {
                currentDropoffOccurrence?.eventLocation = newValue!
            }
            dataSource.map { (o: OccurenceModel) -> (OccurenceModel) in
                if o.eventLocation.name == "" {
                    o.eventLocation = newValue!
                }
                return o
            }
        }
    }

    var pickupLocation: Location? {
        get {
            return currentPickupOccurrence?.defaultLocation
        }
        set {
            if currentPickupOccurrence != nil {
                currentPickupOccurrence?.defaultLocation = newValue!
            }
            dataSource.map { (o: OccurenceModel) -> (OccurenceModel) in
                if o.poolType == "pickup" && o.defaultLocation.name == "" {
                    o.defaultLocation = newValue!
                }
                return o
            }
        }
    }

    var dropoffLocation: Location? {
        get {
            return currentDropoffOccurrence?.defaultLocation
        }
        set {
            if currentDropoffOccurrence != nil {
                currentDropoffOccurrence?.defaultLocation = newValue!
            }
            dataSource.map { (o: OccurenceModel) -> (OccurenceModel) in
                if o.poolType == "dropoff" && o.defaultLocation.name == "" {
                    o.defaultLocation = newValue!
                }
                return o
            }
        }
    }

    var isOneWay: Bool {
        return currentPickupOccurrence == nil || currentDropoffOccurrence == nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setupSubviews()
        relayout()
        getOccurrences()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setUpNavigationBar() {
        if rider != nil {
            subtitleLabel?.text = "\(carpool.name) for \(rider!.firstName)"
        } else {
            subtitleLabel?.text = carpool.descriptionString
        }

        if hideBackButton {
            leftButton.hidden = true
            leftButton.enabled = false
        }
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        if leftButton.enabled {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func rightNavButtonTapped() {
        if rider != nil {
            self.updateRider()
        } else {
            self.updateOccurrences()
        }
    }
    
    func updateOccurrences() {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateOccurrencesInBulk(dataSource) { (success, errStr, objects) in
            onMainThread() {
                LoadingView.dismiss()
                if success {
                    var vc = vcWithID("VolunteerVC") as! VolunteerVC
                    vc.carpool = self.carpool
                    vc.rider = self.rider
                    vc.dataSource = objects as! [OccurenceModel]
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert("Fail to update location", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }

    func updateRider() {
        if self.pickupLocation != nil {
            rider?.pickupLocation = self.pickupLocation!
        }

        if self.dropoffLocation != nil {
            rider?.dropoffLocation = self.dropoffLocation!
        }

        LoadingView.showWithMaskType(.Black)
        dataManager.updateRiderInCarpool(rider!, carpoolID: carpool.id) { (success, error, riderObj) in
            onMainThread() {
                LoadingView.dismiss()
                if success {
                    var vc = vcWithID("VolunteerVC") as! VolunteerVC
                    vc.carpool = self.carpool
                    vc.rider = riderObj as? RiderModel
                    vc.dataSource = self.dataSource
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showAlert("Fail to update rider", messege: error, cancleTitle: "OK")
                }
            }
        }
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
        displayWithDataSource()
    }
    
    @IBAction func segmentControlTapped(sender: UISegmentedControl) {
        segmentSelected(sender.selectedSegmentIndex)
    }

    func donePickingStartLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            self.pickupLocation = Location(name: address, long: long, lati: lati)
            if self.originDestSame {
                self.donePickingEndLocationWithAddress(address)
            }
            self.updateEventViewOnMainThread()
        }
    }
    
    func donePickingEndLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            self.dropoffLocation = Location(name: address, long: long, lati: lati)
            self.updateEventViewOnMainThread()
        }
    }
    
    func donePickingEventLocationWithAddress(address: String) {
        Location.geoCodeAddress(address) { (long, lati) in
            self.eventLocation = Location(name: address, long: long, lati: lati)
            self.updateEventViewOnMainThread()
        }
    }
    
    // MARK: Dataset Display & Management
    // --------------------------------------------------------------------------------------------
    
    func getOccurrences() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getOccurenceOfCarpool(carpool.id, rider: rider) { success, errStr in
            onMainThread() {
                LoadingView.dismiss()
                if success {
                    self.dataSource = self.userManager.volunteerEvents
                    self.collateWithDataSource()
                    self.segmentWithDataSource()
                    self.displayWithDataSource()
                } else {
                    self.showAlert("Failed to fetch carpools", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }
    
    func collateWithDataSource() {
        for occ in dataSource {
            let dayKey = occ.occursAt?.weekDayString()
            let index = dataSourceCollated.indexForKey(dayKey!)
            if index != nil {
                dataSourceCollated[dayKey!]?.append(occ)
            } else {
                dataSourceCollated[dayKey!] = [occ]
            }
        }
    }

    func segmentWithDataSource() {
        segmentControl.removeAllSegments()
        var i = 0
        for title in dataSourceCollated.keys.array {
            segmentControl.insertSegmentWithTitle(title as String, atIndex: i, animated: false)
            i += 1
        }

        if segmentControl.numberOfSegments <= 1 {
            segmentControl.alpha = 0.0
            segmentControl.userInteractionEnabled = false
        }

        segmentControl.selectedSegmentIndex = 0
        segmentSelected(0)
    }

    func segmentSelected(index: Int) {
        let day = segmentControl.titleForSegmentAtIndex(index)

        if let dayCollection = dataSourceCollated[day!] as [OccurenceModel]? {
            let pickups = dayCollection.filter { (o: OccurenceModel) -> Bool in
                return o.poolType == "pickup"
            }
            currentPickupOccurrence = pickups.first

            let dropoffs = dayCollection.filter { (o: OccurenceModel) -> Bool in
                return o.poolType == "dropoff"
            }
            currentDropoffOccurrence = dropoffs.first
        }

        originDestSame = !isOneWay
        toggleForOneWayView()
        relayout()

        displayWithDataSource()
    }

    func displayWithDataSource() {
        if rider != nil {
            self.pickupLocation = rider!.pickupLocation
            self.dropoffLocation = rider!.dropoffLocation

        }

        updateEventViewOnMainThread()
    }

    func updateEventViewOnMainThread() {
        onMainThread() {
            self.eventLocationLabel.text = self.eventLocation?.name
            self.startLocationLabel.text = self.pickupLocation?.name

            if self.originDestSame {
                self.destinationLocationLabel.text = self.pickupLocation?.name
            } else {
                self.destinationLocationLabel.text = self.dropoffLocation?.name
            }
        }
    }
    
}
