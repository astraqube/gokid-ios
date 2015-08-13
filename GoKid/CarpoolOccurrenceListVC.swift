//
//  CarpoolOccurrenceListVC.swift
//  GoKid
//
//  Created by Hoan Ton-That on 8/12/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import Foundation

class CarpoolOccurrenceListVC : BaseVC, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var occurrenceDataSource = [OccurenceModel]()
    var carpool: CarpoolModel!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: "asyncFetchDataAndReloadTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        titleLabel.text = carpool.name
        subtitleLabel.text = carpool.kidName
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self,
            selector: "deleteRideOrCarpool:",
            name:"deleteRideOrCarpool",
            object: nil
        )
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.asyncFetchDataAndReloadTableView()
    }
    
    func deleteRideOrCarpool(sender: AnyObject?) {
        self.asyncFetchDataAndReloadTableView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occurrenceDataSource.count
    }
    
    func checkButtonClickHandler(cell: VolunteerCell, button: UIButton) {
        if let row = tableView.indexPathForCell(cell)?.row {
            let model = self.occurrenceDataSource[row]
            if model.taken {
                self.unRegisterVolunteerForCell(cell, model: model)
            } else{
                self.registerVolunteerForCell(cell, model: model)
            }
        }
    }

//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        //var cell = UITableViewCell()
//        //cell.textLabel?.text = "test"
//        //return cell
//
//        var model = occurrenceDataSource[indexPath.row]
//        
//        let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
//        cell.timeLabel.text = model.occursAtStr
//        cell.locationLabel.text = carpool.startLocation
//        return cell
//
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            //var inviteVC = vcWithID("InviteParentsVC") as! InviteParentsVC
//            //inviteVC.carpool = carpoolsDataSource[indexPath.row]
//            //navigationController?.pushViewController(inviteVC, animated: true)
//            
//            //var carpoolVC = vcWithID("CarpoolOccurrenceListVC") as! CarpoolOccurrenceListVC
//            //carpoolVC.carpool = carpoolsDataSource[indexPath.row]
//            //navigationController?.pushViewController(carpoolVC, animated: true)
//            NSLog("hello hello")
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = occurrenceDataSource[indexPath.row]
        if model.cellType == .None {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.cellType == .Normal {
            let cell = tableView.cellWithID("VolunteerCell", indexPath) as! VolunteerCell
            cell.timeLabel.text = model.poolTimeStringWithSpace()
            cell.poolTypeLabel.text = model.poolType
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = occurrenceDataSource[indexPath.row]
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
    
    func asyncFetchDataAndReloadTableView() {
        dataManager.getOccurenceOfCarpool(carpool.id, comp: { (success, errorStr) -> () in
            if success {
                self.occurrenceDataSource = self.processRawCalendarEvents(self.userManager.volunteerEvents)
//                self.occurrenceDataSource = self.userManager.volunteerEvents
                self.tableView.reloadData()
//                self.showAlert("wow", messege: "works", cancleTitle: "OK")
            } else {
                self.showAlert("Failed to load", messege: errorStr, cancleTitle: "OK")
            }
        })

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

    
//
//    func generateTableDataAndReload() {
//        carpoolsDataSource = userManager.carpools.sorted { (left : CarpoolModel, right : CarpoolModel) -> Bool in
//            if left.startDate == nil || right.startDate == nil { return false}
//            return left.startDate!.isLessThanDate(right.startDate!)
//        }
//        onMainThread() {
//            self.tableView.reloadData()
//        }
//    }


}
