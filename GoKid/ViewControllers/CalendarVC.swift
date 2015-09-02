//
//  CalendarVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import CoreLocation

class CalendarVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var dataSource = [OccurenceModel]()
    var onlyShowOurDrives = false //set true before viewDidLoad to only see our drives
    @IBOutlet weak var menuButton: UIButtonBadged!
    @IBOutlet weak var myDrivesLabel: UILabel!
    @IBOutlet weak var goKidLogo: UIImageView!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if onlyShowOurDrives {
            goKidLogo.hidden = true
            myDrivesLabel.hidden = false
        }
        
        refreshControl.addTarget(self, action: "asyncFetchDataAndReloadTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        setupTableViewContent()

        registerForNotification("deleteRideOrCarpool", action: "asyncFetchDataAndReloadTableView")
    }

    deinit {
        removeNotification(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        generateTableDataAndReload()
        registerForNotification("refreshVolunteerCells", action: "asyncFetchDataAndReloadTableView")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification(self, name: "refreshVolunteerCells")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupTableViewContent() {
        if userManager.userLoggedIn {
            fetchDataAndReloadTableView()
        } else {
            addCreateCarpoolCellToDataSource()
        }
    }

    func asyncFetchDataAndReloadTableView() {
        dataManager.getAllUserOccurrences { (success, errorStr) -> () in
            self.refreshControl.endRefreshing()
            if success {
                self.generateTableDataAndReload()
            } else {
                self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func fetchDataAndReloadTableView() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getAllUserOccurrences { (success, errorStr) -> () in
            LoadingView.dismiss()
            if success {
                self.generateTableDataAndReload()
            } else {
                self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func generateTableDataAndReload() {
        processRawCalendarEvents()
        addCreateCarpoolCellToDataSource()
    }
    
    func tryAddNotificationHeader() {
        if let model = nextDrivingOccurrence() {
            var str = "Hi #name you are driving #date"
            str = str.replace("#name", userManager.info.firstName)
            if model.occursAtStr == "Today" || model.occursAtStr == "Tomorrow" {
                str = str.replace("#date", model.occursAtStr)
            } else {
                if let date = model.occursAt {
                    str = str.replace("#date", "on " + date.shortDateString())
                }
            }
            var cell = OccurenceModel()
            cell.cellType = .Notification
            cell.notification = str
            dataSource.insert(cell, atIndex: 0)
        }
    }
    
    func nextDrivingOccurrence() -> OccurenceModel? {
        for model in self.dataSource {
            if model.cellType != .Normal { continue }
            if model.occursAt == nil || model.occursAt!.isLessThanDate(NSDate(timeIntervalSinceNow: -1 * 60 * 5)) { continue } //ignore older than 5 mins
            if model.volunteer?.id == userManager.info.userID {
                return model
            }
        }
        return nil
    }
    
    func processRawCalendarEvents() {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in userManager.calendarEvents {
            if onlyShowOurDrives && event.volunteer?.id != userManager.info.userID{
                continue
            }
            if event.occursAt!.isLessThanDate(NSDate(timeIntervalSinceNow: -8 * 60 * 60)) { //ignore older than 8 hours
                continue
            }
            if event.occursAtStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.occursAtStr = event.occursAtStr
                data.append(dateCell)
                lastDateStr = event.occursAtStr
            }
            data.append(event)
        }
        dataSource = data
        tryAddNotificationHeader()
    }
    
    func addCreateCarpoolCellToDataSource() {
        var c = OccurenceModel()
        c.cellType = .Add
        dataSource.append(c)

        onMainThread() {
            self.tableView.reloadData()
        }
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    @IBAction func createButtonClicked(sender: UIButton) {
        var vc = vcWithID("BasicInfoVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuButtonClick(sender: UIButton) {
        self.navigationController?.viewDeckController.toggleLeftViewAnimated(true)
    }
    
    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = dataSource[indexPath.row]
        switch model.cellType {
        case .Notification:
            return configNotificationCell(indexPath, model)
        case .Time:
            return configCalendarDateCell(indexPath, model)
        case .Add:
            return configCalendarAddCell(indexPath, model)
        case .Normal:
            return configCalendarCell(indexPath, model)
        default:
            println("Unknown cell")
            return UITableViewCell()
        }
    }
    
    // MARK: Construct TableView Cells
    // --------------------------------------------------------------------------------------------
    
    func configNotificationCell(ip: NSIndexPath, _ model: OccurenceModel) -> CalendarNotificationCell {
        var cell = tableView.cellWithID("CalendarNotificationCell", ip) as! CalendarNotificationCell
        cell.notificationLabel.text = model.notification
        return cell
    }
    
    func configCalendarCell(ip: NSIndexPath, _ model: OccurenceModel) -> CalendarCell {
        var cell : CalendarCell!
        if model == nextDrivingOccurrence() {
            var gCell = tableView.cellWithID("CalendarTimeToGoCell", ip) as! CalendarTimeToGoCell
            gCell.timeToGoTitleLabel.text = "Driving advice loading!"
            gCell.timeToGoTimeLabel.text = ""
            gCell.updatedLabel.text = "Updating riders…"
            dataManager.updateOccurenceRiders(model) { (success, errorStr) -> () in
                gCell.updatedLabel.text = "Updated just now"
                if !success { gCell.timeToGoTitleLabel.text = "Failed to update!"; return }
                var kidName = "kids"
                if let theKidName = model.riders.first?.firstName { kidName = theKidName }
                gCell.timeToGoTitleLabel.text = "Can't keep \(kidName) waiting!"
                var stops = model.riders.map { return $0.stopValue(model.occurrenceType) } + [model.stopValue(model.occurrenceType)]
                if stops.count > 0 {
                    //need to mode for take to event and return from event?
                    stops = ETACalculator.superSortStops(stops, beginningAt: stops.first!, endingAt: stops.last!)
                    var etaDates = ETACalculator.stopDatesFromEstimatesAndArrivalTargetDate(ETACalculator.estimateArrivalTimeForStops(stops), target: model.occursAt!)
                    if let (departDate, stop) = etaDates.first {
                        if departDate.isLessThanDate(NSDate(timeIntervalSinceNow: 300)) {
                            gCell.timeToGoTimeLabel.text = "It's go time!"
                        } else {
                            gCell.timeToGoTimeLabel.text = "Go time is \(departDate.timeString())!"
                        }
                    }
                }
            }
            cell = gCell
        } else {
            cell = tableView.cellWithID("CalendarCell", ip) as! CalendarCell
        }
        
        cell.loadModel(model)
        cell.presenter = self
        return cell
    }
    
    func configCalendarDateCell(ip: NSIndexPath, _ model: OccurenceModel) -> CalendarDateCell {
        var cell = tableView.cellWithID("CalendarDateCell", ip) as! CalendarDateCell
        cell.dateLabel.text = model.occursAtStr
        return cell
    }
    
    func configCalendarAddCell(ip: NSIndexPath, _ model: OccurenceModel) -> CalendarAddCell {
        var cell = tableView.cellWithID("CalendarAddCell", ip) as! CalendarAddCell
        return cell
    }
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = dataSource[indexPath.row]
        switch model.cellType {
        case .Notification:
            return 72.0
        case .Time:
            return 39.0
        case .Add:
            return 77.0
        case .Normal:
            if model == nextDrivingOccurrence() {
                return 190
            }
            return 134.0
        default:
            return 50.0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == dataSource.count-1 {
            self.createButtonClicked(UIButton())
        }
        if tableView.cellForRowAtIndexPath(indexPath) as? CalendarCell != nil {
            LoadingView.showWithMaskType(.Black)
            let model = dataSource[indexPath.row]
            updateOccurrenceAndGetImages(model) { (success) -> () in
                LoadingView.dismiss()
                if success {
                    self.showOccurenceVCWithModel(model)
                }
            }
        }
    }
    
    var currentOccurrenceImagesByURL : [String : UIImage]?
    func getImagesForOccurrence(occurrence : OccurenceModel, then : (()->())){
        currentOccurrenceImagesByURL = nil
        let imageURLs = [occurrence.poolDriverImageUrl] + occurrence.riders.reduce([String]()) { (U, T) -> [String] in
            let url = T.thumURL as NSString
            if url.length > 0 && url.containsString("default") == false { return U + [T.thumURL] }
            return U
        }
        imageManager.getImagesAtURLs(imageURLs, callback: { (imagesByURL) -> () in
            self.currentOccurrenceImagesByURL = imagesByURL
            then()
        })
    }
    
    func updateOccurrenceAndGetImages(occurrence: OccurenceModel, then: ((success: Bool)->())){
        dataManager.updateOccurenceRiders(occurrence) { (occ, errorStr) -> () in
            if occ {
                self.getImagesForOccurrence(occurrence) { () -> () in
                    then(success: true)
                }
            } else {
                self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
                then(success: false)
            }
        }
    }
    
    func showOccurenceVCWithModel(model: OccurenceModel) {
        var vc = vcWithID("DetailMapVC") as! DetailMapVC
        vc.canEdit = model.carpool.isOwner
        vc.onEditButtonPressed = { (vc: DetailMapVC) in
            UserManager.sharedInstance.currentCarpoolModel = model.carpool
            UserManager.sharedInstance.currentCarpoolModel.kidName = model.riders[0].firstName
            var carpoolEditVC = vcWithID("CarpoolEditVC") as! CarpoolEditVC
            //carpoolEditVC.carpool = model.carpool
            carpoolEditVC.occurrence = model
            carpoolEditVC.onOccurrenceEdited = { (newOccurrence) in
                vc.navigation = self.navigationForModel(newOccurrence)
                vc.metadata = self.mapMetadataForModel(newOccurrence)
                vc.setupView()
            }
            vc.navigationController?.pushViewController(carpoolEditVC, animated: true)
        }
        vc.onDriverImagePressed = { (vc: DetailMapVC) in
            // FIXME: integrate this back to VolunteerCell
        }

        let myRiders = model.riders.filter { (r: RiderModel) -> Bool in
            return r.isInMyTeam
        }

        vc.canOptOut = myRiders.count > 0

        vc.onOptOutButtonPressed = { (vc: DetailMapVC) in
            var optOutRider = myRiders.first
            if optOutRider == nil { return }
            var optOutSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let optOutString = "Opt Out \(optOutRider!.firstName)"
            optOutSheet.addAction(UIAlertAction(title: optOutString, style: UIAlertActionStyle.Destructive, handler: { (z: UIAlertAction!) -> Void in
                vc.navigationController?.popViewControllerAnimated(true)
                LoadingView.showWithMaskType(.Black)
                self.dataManager.deleteFromOccurenceRiders(optOutRider!, occ: model, comp: { (success, errorStr) -> () in
                    LoadingView.dismiss()
                    if success {
                        model.riders.removeAtIndex(find(model.riders, optOutRider!)!)
                        self.fetchDataAndReloadTableView()
                    } else {
                        self.showAlert("Failed to opt out rider", messege: errorStr, cancleTitle: "OK")
                    }
                })
            }))
            optOutSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(optOutSheet, animated: true, completion: nil)
        }
        vc.navigation = self.navigationForModel(model)
        vc.metadata = self.mapMetadataForModel(model)
        self.navigationController?.pushViewController(vc, animated: true)
        self.setStatusBarColorDark()
    }
    
    func navigationForModel(model : OccurenceModel) -> Navigation {
        var eventStop = model.stopValue(model.occurrenceType)
        var riderStops = [Stop]()
        for rider in model.riders {
            let stop = rider.stopValue(model.occurrenceType)
            if (rider.thumURL as NSString).containsString("default") == false {
                stop.thumbnailImage = currentOccurrenceImagesByURL?[rider.thumURL]
            }
            riderStops.append(stop)
        }
        
        var pickups : [Stop]!
        var dropoffs : [Stop]!
        
        switch model.occurrenceType {
        case .Pickup:
            pickups = riderStops
            dropoffs = [eventStop]
        case .Dropoff:
            pickups = [eventStop]
            dropoffs = riderStops.reverse()
        }
        
        var navigation = Navigation()
        navigation.setup(pickups, dropoffs:dropoffs);
        navigation.onStopStateChanged = { (nav : Navigation, stop: Stop) in
            let riderId = stop.stopID as? NSString
            if riderId != nil && stop.state == .Arrived {
                var rider = RiderModel()
                rider.riderID = riderId!.integerValue
                self.dataManager.notifyRider(RiderNotificationType.Arriving , occurrence: model, rider: rider, comp: { (success, errorString) -> () in
                    if !success {
                        self.showAlert("Failed to notify rider of arrival", messege: "You may want to message them!", cancleTitle: "OK")
                    }
                })
            }
            if navigation.currentStop == nil {
                self.dataManager.notifyRiders(RiderNotificationType.RideComplete , occurrence: model, comp: { (success, errorString) -> () in
                    if !success {
                        self.showAlert("Failed to notify parents of ride completion!", messege: "You may want to message parents!", cancleTitle: "OK")
                    }
                })
            }
        }
        navigation.onLocationUpdate = { (error: NSError?, location : CLLocation!) in
            if let error = error { return println("onLocationUpdate error: \(error.description)") }
            self.dataManager.putOccurrenceCurrentLocation(location, occurrence: model, comp: { (success, errorString) -> () in
                if !success {
                    println("failed to onLocationUpdate + putOccurrenceCurrentLocation")
                }
            })
        }
        return navigation
    }
    
    func mapMetadataForModel(model : OccurenceModel) -> MapMetadata {
        var canNavigate =  model.volunteer?.id != nil && model.volunteer?.id == self.userManager.info.userID
        var driverImage = currentOccurrenceImagesByURL?[model.poolDriverImageUrl]
        return MapMetadata(name: model.poolname, thumbnailImage: driverImage, date: model.occursAt!, canNavigate: canNavigate, id: model.occurenceID, type: model.occurrenceType )
    }
    
}


extension OccurenceModel {
    var occurrenceType : OccurenceType {
        return (self.poolType == "dropoff") ? .Dropoff : .Pickup
    }
    var volunteerable : Bool {
        var volunteerID = self.volunteer?.id
        var volunteerable = false;
        if volunteerID == nil || volunteerID == 0 || volunteerID == UserManager.sharedInstance.info.userID {
            volunteerable = true
        }
        return volunteerable
    }
    var alreadyVolunteered : Bool {
        var volunteerID = self.volunteer?.id
        let already = volunteerID == UserManager.sharedInstance.info.userID
        return already
    }
}

protocol Stopify {
    func stopValue(type: OccurenceType) -> Stop
}

extension RiderModel : Stopify {
    func stopValue(type: OccurenceType) -> Stop {
        var location : Location!
        switch type{
        case .Dropoff:
            location = self.dropoffLocation
        default:
            location = self.pickupLocation
        }
        return Stop(coordinate: CLLocationCoordinate2D(latitude: location.lati, longitude: location.long) , name: "\(self.firstName) \(self.lastName)", address: location.name, phoneNumber: self.phoneNumber, stopID: NSNumber(integer: self.riderID).stringValue, thumbnailImage: nil)
    }
}


extension OccurenceModel : Stopify {
    func stopValue(type: OccurenceType) -> Stop {
        return Stop(coordinate: CLLocationCoordinate2D(latitude: self.eventLocation.lati, longitude: self.eventLocation.long) , name: self.poolname, address: self.eventLocation.name, phoneNumber: nil, stopID: self, thumbnailImage: nil)
    }
}
