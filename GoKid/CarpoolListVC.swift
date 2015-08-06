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
    var invitesDataSource = [InvitationModel]()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: "asyncFetchDataAndReloadTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        fetchDataAndReloadTableView()
        fetchInvitations()
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
            var model = invitesDataSource[indexPath.row]
            return configCarpoolInviteCell(indexPath, model)
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == ListSection.Carpools.rawValue {
            var inviteVC = vcWithID("InviteParentsVC") as! InviteParentsVC
            inviteVC.carpool = carpoolsDataSource[indexPath.row]
            navigationController?.pushViewController(inviteVC, animated: true)
        }
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
        carpoolsDataSource = userManager.carpools.sorted { (left : CarpoolModel, right : CarpoolModel) -> Bool in
            if left.startDate == nil || right.startDate == nil { return false}
            return left.startDate!.isLessThanDate(right.startDate!)
        }
        onMainThread() {
            self.tableView.reloadData()
        }
    }
}


// MARK: Invitations

extension CarpoolListVC {

    func fetchInvitations() {
        dataManager.getInvitations() { (success, error) in
            if success {
                self.invitesDataSource = self.userManager.invitations
                onMainThread() {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func configCarpoolInviteCell(ip: NSIndexPath, _ model: InvitationModel) -> CarpoolInviteCell {
        var cell = tableView.cellWithID("CarpoolInviteCell", ip) as! CarpoolInviteCell
        cell.invitation = model
        cell.onAccept = self.onAcceptInvitation
        cell.onDecline = self.onDeclineInvitation
        cell.refreshContent()
        return cell
   }

    func onAcceptInvitation(invitation: InvitationModel) {
        LoadingView.showWithMaskType(.Black)
        dataManager.acceptInvite(invitation.inviteID) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                onMainThread() {
                    self.fetchInvitations()
                    var vc = vcWithID("InviteRelationshipVC") as! InviteRelationshipVC
                    vc.invitation = invitation
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showAlert("Failed to accept carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    func onDeclineInvitation(invitation: InvitationModel) {
        LoadingView.showWithMaskType(.Black)
        dataManager.declineInvite(invitation.inviteID) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                onMainThread() {
                    self.fetchInvitations()
                }
            } else {
                self.showAlert("Failed to decline carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
