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
    @IBOutlet weak var myDrivesLabel: UILabel!
    @IBOutlet weak var goKidLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTableViewContent()
        if onlyShowOurDrives {
            goKidLogo.hidden = true
            myDrivesLabel.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTableViewContent() {
        if userManager.userLoggedIn {
            fetchDataAndReloadTableView()
        } else {
            addCreateCarpoolCellToDataSource()
            tableView.reloadData()
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
        onMainThread() {
            self.tableView.reloadData()
        }
    }
    
    func tryAddNotificationHeader() {
        // we have one last cell for add carpool thus here is 2
        if dataSource.count >= 3 {
            var model = dataSource[1]
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
    
    func processRawCalendarEvents() {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in userManager.calendarEvents {
            if onlyShowOurDrives && event.volunteer?.id != userManager.info.userID{
                continue
            }
            if event.occursAt!.isLessThanDate(NSDate(timeIntervalSinceNow: -24 * 60 * 60)) {
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
        var cell = tableView.cellWithID("CalendarCell", ip) as! CalendarCell
        cell.nameLabel.text = model.poolname
        cell.timeLabel.text = model.pooltimeStr
        cell.typeLabel.text = model.poolType
        if model.poolType == "dropoff" {
            cell.pickupIcon.hidden = true
            cell.dropoffIcon.hidden = false
        }else {
            cell.pickupIcon.hidden = false
            cell.dropoffIcon.hidden = true
        }
        for (index, riderImageView) in enumerate(cell.pickupImageCollection) {
            let rider : RiderModel? = (model.riders.count > index) ? model.riders[index] : nil
            if rider != nil {
                riderImageView.nameString = "\(rider!.firstName) \(rider!.lastName)"
                //riderImageView.image = rider.thumURL //gotta get images
                riderImageView.hidden = false
            } else {
                riderImageView.hidden = true
            }
        }
        cell.profileImageView.image = nil
        imageManager.setImageToView(cell.profileImageView, urlStr: model.poolDriverImageUrl)
        weak var wModel = model
        cell.onProfileImageViewTapped = { () -> (Void) in
            if wModel == nil { return }
            var volunteerID = wModel?.volunteer?.id
            var volunteerable = false;
            if volunteerID == nil || volunteerID == 0 || volunteerID == self.userManager.info.userID {
                volunteerable = true
            }
            var volunteerActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            var volunteerTitle = "Volunteer to \(wModel!.poolType)"
            var unvolunteer = false
            if volunteerID == self.userManager.info.userID {
                volunteerTitle = "Unvolunteer"
                unvolunteer = true
            }
            volunteerActionSheet.addAction(UIAlertAction(title: volunteerTitle, style: UIAlertActionStyle.Destructive, handler: { (z: UIAlertAction!) -> Void in
                LoadingView.showWithMaskType(.Black)
                if unvolunteer {
                    self.dataManager.unregisterForOccurence(model.carpoolID, occurID: model.occurenceID) { (success, errStr) in
                        LoadingView.dismiss()
                        onMainThread() {
                            if success {
                                cell.profileImageView.image = nil
                                self.fetchDataAndReloadTableView()
                            } else {
                                self.showAlert("Fail to volunteer", messege: errStr, cancleTitle: "OK")
                            }}
                    }
                } else {
                    self.dataManager.registerForOccurence(model.carpoolID, occurID: model.occurenceID) { (success, errStr) in
                        LoadingView.dismiss()
                        onMainThread() {
                            if success {
                                self.imageManager.setImageToView(cell.profileImageView, urlStr: self.userManager.info.thumURL)
                                self.fetchDataAndReloadTableView()
                            } else {
                                self.showAlert("Fail to volunteer", messege: errStr, cancleTitle: "OK")
                            }}
                    }
                }
            }))
            volunteerActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(volunteerActionSheet, animated: true, completion: nil)
        }
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
            dataManager.updateOccurenceRiders(dataSource[indexPath.row]) { (success, errorStr) -> () in
                LoadingView.dismiss()
                if success {
                    var model = self.dataSource[indexPath.row]
                    self.showOccurenceVCWithModel(model)
                } else {
                    self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
                }
            }
        }
    }
    
    func showOccurenceVCWithModel(model: OccurenceModel) {
        var vc = vcWithID("DetailMapVC") as! DetailMapVC
        vc.onEditButtonPressed = { (vc: DetailMapVC) in
            UserManager.sharedInstance.currentCarpoolModel = CarpoolModel()
            UserManager.sharedInstance.currentCarpoolModel.id = model.carpoolID
            UserManager.sharedInstance.currentCarpoolModel.name = model.poolname
            var inviteVC = vcWithID("InviteParentsVC") as! InviteParentsVC
            inviteVC.hideForwardNavigationButtons = true
            vc.navigationController?.pushViewController(inviteVC, animated: true)
        }
        vc.onOptOutButtonPressed = { (vc: DetailMapVC) in
            var optOutRider = model.riders.first
            if optOutRider == nil { return }
            var optOutSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let optOutString = "Opt Out \(optOutRider!.firstName)"
            optOutSheet.addAction(UIAlertAction(title: optOutString, style: UIAlertActionStyle.Destructive, handler: { (z: UIAlertAction!) -> Void in
                vc.navigationController?.popViewControllerAnimated(true)
                LoadingView.showWithMaskType(.Black)
                self.dataManager.deleteFromOccurenceRiders(optOutRider!, occ: model, comp: { (success, errorStr) -> () in
                    LoadingView.dismiss()
                    if success {
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
        var navigation = Navigation()
        var pickups = [Stop]()
        for rider in model.riders {
            pickups.append(Stop(coordinate: CLLocationCoordinate2D(latitude: rider.pickupLocation.lati, longitude: rider.pickupLocation.long) , name: "\(rider.firstName) \(rider.lastName)", address: rider.pickupLocation.name, phoneNumber: rider.phoneNumber, stopID: NSNumber(integer: rider.riderID).stringValue, thumbnailImage: nil))
        }
        var dropoffs = [
            Stop(coordinate: CLLocationCoordinate2D(latitude: model.eventLocation.lati, longitude: model.eventLocation.long) , name: model.poolname, address: model.eventLocation.name, phoneNumber: nil, stopID: String(model.occurenceID), thumbnailImage: nil)
        ]
        navigation.setup(pickups, dropoffs:dropoffs);
        navigation.onStopStateChanged = { (nav : Navigation, stop: Stop) in
            if stop.state == .Arrived {
                var rider = RiderModel()
                rider.riderID = stop.stopID.integerValue
                self.dataManager.notifyRiderStopArrival(model, rider: rider, comp: { (success, errorString) -> () in
                    if !success {
                        self.showAlert("Failed to notify rider of arrival", messege: "You may want to message them!", cancleTitle: "OK")
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
        return MapMetadata(name: model.poolname, thumbnailImage: UIImage(named: "emma"), date: model.occursAt!, canNavigate: canNavigate, id: model.occurenceID, type: (model.poolType == "dropoff") ? .Dropoff : .Pickup )
    }

}
