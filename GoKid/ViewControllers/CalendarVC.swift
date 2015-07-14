//
//  CalendarVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CalendarVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [OccurenceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTableViewContent()
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
        dataManager.getAllUserCarpools { (success, errorStr) -> () in
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
            if model.poolDateStr == "Today" || model.poolDateStr == "Tomorrow" {
                str = str.replace("#date", model.poolDateStr)
            } else {
                if let date = model.poolDate {
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
            if event.poolDateStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.poolDateStr = event.poolDateStr
                data.append(dateCell)
                lastDateStr = event.poolDateStr
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
        if model.poolType == "DROP OFF" {
            cell.pickupIcon.hidden = true
            cell.dropoffIcon.hidden = false
        }else {
            cell.pickupIcon.hidden = false
            cell.dropoffIcon.hidden = true
        }
        cell.profileImageView.image = nil
        imageManager.setImageToView(cell.profileImageView, urlStr: model.poolDriverImageUrl)
        weak var wModel = model
        cell.onProfileImageViewTapped = { () -> (Void) in
            if wModel == nil { return }
            var volunteerActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            var volunteerTitle = "Volunteer to \(wModel!.poolType)"
            volunteerActionSheet.addAction(UIAlertAction(title: volunteerTitle, style: UIAlertActionStyle.Destructive, handler: { (z: UIAlertAction!) -> Void in
                UIAlertView(title: "Program faster!", message: nil, delegate: nil, cancelButtonTitle: "Okay").show()
            }))
            volunteerActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(volunteerActionSheet, animated: true, completion: nil)
        }
        return cell
    }
    
    func configCalendarDateCell(ip: NSIndexPath, _ model: OccurenceModel) -> CalendarDateCell {
        var cell = tableView.cellWithID("CalendarDateCell", ip) as! CalendarDateCell
        cell.dateLabel.text = model.poolDateStr
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
            return 130.0
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
                    var navigation = Navigation()
                    var pickups = [
                        // right now we only have one stop for each
                        // pick-up/drop-off we will add more later
                        // Stop(occurrence: model)
                        Stop(coordinate: CLLocationCoordinate2DMake(37.4528, -122.1833), name: "Menlo's House", address: "123 Fake St 91210", phoneNumber: "18002831337", stopID: "1", thumbnailImage: UIImage(named: "test_userImage")),
                        Stop(coordinate: CLLocationCoordinate2DMake(37.4598, -122.1893), name: "Kid's House", address: "4821 Fake Ln 91210", phoneNumber: "18002831437", stopID: "2", thumbnailImage: nil),
                        Stop(coordinate: CLLocationCoordinate2DMake(37.4608, -122.2093), name: "Another Kid's House", address: "8912 Big Fake Ave 91211", phoneNumber: "18002831537", stopID: "3", thumbnailImage: nil)
                    ]
                    
                    var dropoffs = [
                        Stop(coordinate: CLLocationCoordinate2DMake(37.783333, -122.416667), name: "Soccer Club", address: "4 Soccer Way 92118", phoneNumber: "18002831637", stopID: "10", thumbnailImage: nil)
                    ]
                    navigation.setup(pickups, dropoffs:dropoffs);
                    
                    var vc = vcWithID("DetailMapVC") as! DetailMapVC
                    vc.navigation = navigation
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.setStatusBarColorDark() //dude, this is lame, try func preferredStatusBarStyle
                } else {
                    self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
                }
            }
        }
    }
}
