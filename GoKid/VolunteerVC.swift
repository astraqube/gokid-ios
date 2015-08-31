//
//  VolunteerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    var carpool: CarpoolModel!
    var rider: RiderModel?

    var fromCarpoolList = false

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [OccurenceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColorDark()
        self.subtitleLabel?.text = carpool.descriptionString

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: "deleteRideOrCarpool:",
            name:"deleteRideOrCarpool",
            object: nil
        )

        if !fromCarpoolList {
            rightButton.setImage(UIImage(named: "next_arrow"), forState: UIControlState.Normal)
        } else {
            rightButton.enabled = carpool.isOwner
            rightButton.hidden = !carpool.isOwner
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tryLoadTableData()
    }

    func deleteRideOrCarpool(sender: AnyObject?) {
        tryLoadTableData()
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func rightNavButtonTapped() {
        if carpool.isOwner {
            if fromCarpoolList {
                var vc = vcWithID("CarpoolEditVC") as! CarpoolEditVC
                vc.occurrence = dataSource[1]
                navigationController?.pushViewController(vc, animated: true)
            } else {
                var vc = vcWithID("InviteParentsVC") as! InviteParentsVC
                vc.carpool = self.carpool
                vc.hideForwardNavigationButtons = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainController = appDelegate.window!.rootViewController as! MainStackVC
            mainController.determineStateForViews()
        }
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: TableView DataSource Method
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = dataSource[indexPath.row]
        if model.cellType == .None {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.cellType == .Normal {
            let cell = tableView.cellWithID("VolunteerCell", indexPath) as! VolunteerCell
            cell.loadModel(model)
            cell.presenter = self
            return cell
        } else if model.cellType == .Time {
            let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
            cell.timeLabel.text = model.occursAtStr
            cell.locationLabel.text = model.eventLocation.name
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var model = dataSource[indexPath.row]
        if model.cellType == .Normal && carpool.isOwner && fromCarpoolList {
            var vc = vcWithID("CarpoolEditVC") as! CarpoolEditVC
            vc.occurrence = model
            navigationController?.pushViewController(vc, animated: true)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = dataSource[indexPath.row]
        switch model.cellType {
        case .None:
            return 20.0
        case .Normal:
            return 70.0
        case .Time:
            return 60.0
        default:
            return 50.0
        }
    }
    
    func tryLoadTableData() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getOccurenceOfCarpool(carpool.id, rider: rider) { (success: Bool, errorStr: String) in
            LoadingView.dismiss()
            if success {
                if self.userManager.volunteerEvents.count == 0 {
                    // we were deleted
                    self.navigationController?.popViewControllerAnimated(false)
                    return
                }
                
                self.dataSource = self.processRawCalendarEvents(self.userManager.volunteerEvents)
                self.tableView.reloadData()
            } else {
                self.showAlert("Error", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    func reloadTableData() {
        if dataSource.count > 0 {
            dataSource = processRawCalendarEvents(self.userManager.volunteerEvents)
            tableView.reloadData()
        }
    }

    func processRawCalendarEvents(events: [OccurenceModel]) -> [OccurenceModel] {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in events {
            if event.occursAtStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.occursAtStr = event.occursAtStr
                dateCell.eventLocation = event.eventLocation
                data.append(dateCell)
                lastDateStr = event.occursAtStr
            }
            data.append(event)
        }
        return data
    }

}
