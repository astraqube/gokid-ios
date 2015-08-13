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
        tryLoadTableData()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: "deleteRideOrCarpool:",
            name:"deleteRideOrCarpool",
            object: nil
        )

        if !fromCarpoolList {
            rightButton.setImage(UIImage(named: "next_arrow"), forState: UIControlState.Normal)
        }
    }
    
    func deleteRideOrCarpool(sender: AnyObject?) {
        tryLoadTableData()
    }

    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func rightNavButtonTapped() {
        if fromCarpoolList {
            var vc = vcWithID("CarpoolEditVC") as! CarpoolEditVC
            vc.occurrence = dataSource[1]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if carpool.isOwner {
                var vc = vcWithID("InviteParentsVC") as! InviteParentsVC
                vc.carpool = self.carpool
                vc.hideForwardNavigationButtons = false
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                var vc = vcWithID("CarpoolSucceedVC") as! CarpoolSucceedVC
                vc.carpool = self.carpool
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func checkButtonClickHandler(cell: VolunteerCell, button: UIButton) {
        if let row = tableView.indexPathForCell(cell)?.row {
            let model = self.dataSource[row]
            if model.taken {
                self.unRegisterVolunteerForCell(cell, model: model)
            } else{
                self.registerVolunteerForCell(cell, model: model)
            }
        }
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
            cell.timeLabel.text = model.poolTimeStringWithSpace()

            if model.poolType == "pickup" {
                cell.poolTypeLabel.text = kGKPickup
            } else {
                cell.poolTypeLabel.text = kGKDropoff
            }

            cell.checkButtonHandler = checkButtonClickHandler
            // setup cell image
            if model.poolDriverImageUrl != "" {
                imageManager.setImageToView(cell.driverImageView, urlStr: model.poolDriverImageUrl)
            } else {
                cell.driverImageView.image = UIImage(named: "checkCirc")
            }
            // setup driver name
            if model.poolDriverName == "No Driver yet" {
                cell.driverTitleLabel.text = "Volunteer to Drive"
            } else {
                cell.driverTitleLabel.text = model.poolDriverName
            }
            return cell
        } else if model.cellType == .Time {
            let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
            cell.timeLabel.text = model.occursAtStr
            cell.locationLabel.text = carpool.startLocation
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var model = dataSource[indexPath.row]
        if model.cellType == .Normal {
            var vc = vcWithID("CarpoolEditVC") as! CarpoolEditVC
            vc.occurrence = model
            navigationController?.pushViewController(vc, animated: true)
        } else if model.cellType == .Time {
            var vc = vcWithID("CarpoolEditVC") as! CarpoolEditVC
            vc.occurrence = dataSource[indexPath.row + 1]  // hardcode first occurrence
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
    
    func processRawCalendarEvents(events: [OccurenceModel]) -> [OccurenceModel] {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in events {
            if event.occursAtStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.occursAtStr = event.occursAtStr
                data.append(dateCell)
                lastDateStr = event.occursAtStr
            }
            data.append(event)
        }
        return data
    }

    func unRegisterVolunteerForCell(cell: VolunteerCell, model: OccurenceModel) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.unregisterForOccurence(model.carpoolID, occurID: model.occurenceID) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    cell.driverImageView.image = UIImage(named: "checkCirc")
                    model.taken = !model.taken
                } else {
                    self.showAlert("Error", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }

    func registerVolunteerForCell(cell: VolunteerCell, model: OccurenceModel) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.registerForOccurence(model.carpoolID, occurID: model.occurenceID) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    self.imageManager.setImageToView(cell.driverImageView, urlStr: self.userManager.info.thumURL)
                    model.taken = !model.taken
                    model.poolDriverImageUrl = self.userManager.info.thumURL
                } else {
                    self.showAlert("Error", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }

}
