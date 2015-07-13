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
    
    struct Address {
        var name: String = ""
        var long: CLLocationDegrees = 0.0
        var lati: CLLocationDegrees = 0.0
    }
    
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
    var dataSource = [(CalendarModel, CalendarModel)]() // drop pick
    
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
        subtitleLabel?.text = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
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
            var add = Address(name: address, long: long, lati: lati)
            self.updateOccrenceWithAddress(self.dataSource[i].0, add)
            if self.originDestSame {
                self.updateOccrenceWithAddress(self.dataSource[i].1, add)
            }
            self.updateEventViewOnMainThread()
            self.syncLocalEventsWithSever()
        }
    }
    
    func donePickingEndLocationWithAddress(address: String) {
        geoCodeAddress(address) { (long, lati) in
            var i = self.segmentControl.selectedSegmentIndex
            var add = Address(name: address, long: long, lati: lati)
            self.updateOccrenceWithAddress(self.dataSource[i].1, add)
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
            generateDataSource()
            displayWithDataSource()
        } else {
            showAlert("Fail to fetch carpools", messege: errStr, cancleTitle: "OK")
        }
    }
    
    // this is very bad but devon insist we grop occrence by time
    // as a reault this cause week connction between pickup and drop out
    // might be a bug in the future
    func generateDataSource() {
        var lastEvent = CalendarModel()
        for eve in userManager.volunteerEvents {
            if eve.poolDateStr == lastEvent.poolDateStr {
                dataSource.append((lastEvent, eve))
                continue
            }
            lastEvent = eve
        }
    }
    
    func displayWithDataSource() {
        if dataSource.count >= 10 {
            segmentControl.alpha = 0.0
            segmentControl.userInteractionEnabled = false
        } else {
            segmentControl.removeAllSegments()
            for (i, data) in enumerate(dataSource) {
                var title = data.0.poolDate?.weekDayString()
                segmentControl.insertSegmentWithTitle(title, atIndex: i, animated: false)
            }
            segmentControl.selectedSegmentIndex = 0
            updateEventViewOnMainThread()
        }
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
            self.startLocationLabel.text = self.dataSource[i].0.poolLocation
            self.destinationLocationLabel.text = self.dataSource[i].1.poolLocation
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
    
    func updateOccrenceWithAddress(occ: CalendarModel, _ add: Address) {
        occ.locationLongtitude = add.long
        occ.locationLatitude = add.lati
        occ.poolLocation = add.name
    }
}



