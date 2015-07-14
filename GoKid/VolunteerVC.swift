//
//  VolunteerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [OccurenceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tryLoadTableData()
    }
    
    func setupNavigationBar() {
        self.subtitleLabel?.text = userManager.currentCarpoolDescription()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func rightNavButtonTapped() {
        var vc = vcWithID("InviteParentsVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func checkButtonClickHandler(cell: VolunteerCell, button: UIButton) {
        if let row = tableView.indexPathForCell(cell)?.row {
            showActionSheet(cell)
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
            cell.poolTypeLabel.text = model.poolType
            cell.checkButtonHandler = checkButtonClickHandler
            if model.poolDriverName == "No Driver yet" { cell.driverTitleLabel.text = "Volunteer to Drive" }
            else { cell.driverTitleLabel.text = model.poolDriverName }
            return cell
        } else if model.cellType == .Time {
            let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
            cell.timeLabel.text = model.poolDateStr
            cell.locationLabel.text = userManager.currentCarpoolModel.startLocation
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
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
    
    // MARK: NetWork Create Carpool
    // --------------------------------------------------------------------------------------------
    
    func createCarpool() {
      var model = userManager.currentCarpoolModel
      dataManager.createCarpool(model) { (success, errorStr) in
        if success {
          var vc = vcWithID("InviteParentsVC")
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          self.showAlert("Alert", messege: "Cannot create Carpool " + errorStr, cancleTitle: "OK")
        }
      }
    }
    
    func tryLoadTableData() {
        if userManager.userLoggedIn {
            LoadingView.showWithMaskType(.Black)
            dataManager.getOccurenceOfCarpool(userManager.currentCarpoolModel.id, comp: handleGetVolunteerList)
        } else {
            showAlert("Cannot fetch data", messege: "You are not logged in", cancleTitle: "OK")
        }
    }
    
    func handleGetVolunteerList(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            dataSource = processRawCalendarEvents(userManager.volunteerEvents)
            reloadWithDataSourceOnMainThread()
        } else {
            self.showAlert("Fail to fetch vlounteer list", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func processRawCalendarEvents(events: [OccurenceModel]) -> [OccurenceModel] {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in events {
            if event.poolDateStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.poolDateStr = event.poolDateStr
                data.append(dateCell)
                lastDateStr = event.poolDateStr
            }
            data.append(event)
        }
        return data
    }
    
    func reloadWithDataSourceOnMainThread() {
        onMainThread() {
            self.tableView.reloadData()
        }
    }
}

