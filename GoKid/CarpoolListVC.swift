//
//  CarpoolListVC.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

enum ListSection : Int {
    case Invites
    case Carpools
    case AddNew
}

class CarpoolListVC : BaseVC, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var carpoolsDataSource = [CarpoolModel]()
    var invitesDataSource = [AnyObject]()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        fetchDataAndReloadTableView()
        
        refreshControl.addTarget(self, action: "asyncFetchDataAndReloadTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3 //invites carpools newCarpool
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == ListSection.Carpools.rawValue {
            return carpoolsDataSource.count
        }
        if section == ListSection.Invites.rawValue {
            return invitesDataSource.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == ListSection.AddNew.rawValue {
            var cell = tableView.cellWithID("CalendarAddCell", indexPath) as! CalendarAddCell
            return cell
        }
        if indexPath.section == ListSection.Carpools.rawValue {
            var model = carpoolsDataSource[indexPath.row]
            return configCarpoolCell(indexPath, model)
        }
        if indexPath.section == ListSection.Invites.rawValue {
            var model: AnyObject = invitesDataSource[indexPath.row]
            var cell = tableView.cellWithID("CarpoolInviteCell", indexPath) as! CarpoolInviteCell
            return cell
        }
        return UITableViewCell()
    }
    
    func configCarpoolCell(ip: NSIndexPath, _ model: CarpoolModel) -> CarpoolListCell {
        var cell = tableView.cellWithID("CarpoolListCell", ip) as! CarpoolListCell
        if model.startDate != nil && model.endDate != nil {
            cell.timeLabel.text = "\(model.startDate!.shortDateString()) - \(model.endDate!.shortDateString())"
        } else {
            cell.timeLabel.text = "loading…"
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
        cell.nameLabel.text = model.name
        return cell
    }
    
    @IBAction func menuButtonClick(sender: UIButton) {
        self.navigationController?.viewDeckController.toggleLeftViewAnimated(true)
    }
    
    @IBAction func createButtonClicked(sender: UIButton) {
        var vc = vcWithID("BasicInfoVC")
        navigationController?.pushViewController(vc, animated: true)
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
        dataManager.getCarpools { (success, errorStr) -> () in
            LoadingView.dismiss()
            if success {
                self.generateTableDataAndReload()
            } else {
                self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func generateTableDataAndReload() {
        carpoolsDataSource = userManager.carpools
        onMainThread() {
            self.tableView.reloadData()
        }
    }

}
