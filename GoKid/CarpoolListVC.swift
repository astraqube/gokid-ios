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
    @IBOutlet weak var menuButton: UIButtonBadged!
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
        
        refreshControl.addTarget(self, action: "fetchDataAndReloadTableView", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)

        fetchDataAndReloadTableView()
        
        registerForNotification("deleteRideOrCarpool", action: "fetchDataAndReloadTableView")
        registerForNotification("invitationsUpdated", action: "setNotificationsBadge")
        registerForNotification(UIApplicationDidBecomeActiveNotification, action: "setNotificationsBadge")
    }

    deinit {
        removeNotification(self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColorLight()
        navigationController?.setNavigationBarHidden(true, animated: true)
        setNotificationsBadge()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        generateTableDataAndReload()
        postNotification("requestForPhoneNumber")
    }

    func setNotificationsBadge() {
        menuButton.setBadge(InvitationModel.InvitationCount)
        generateTableDataAndReload()
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
            let cell = tableView.cellWithID("CalendarAddCell", indexPath) as! CalendarAddCell
            return cell
        }
        if indexPath.section == ListSection.Carpools.rawValue {
            let model = carpoolsDataSource[indexPath.row]
            return configCarpoolCell(indexPath, model)
        }
        if indexPath.section == ListSection.Invites.rawValue {
            let model = invitesDataSource[indexPath.row]
            return configCarpoolInviteCell(indexPath, model)
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == ListSection.Carpools.rawValue {
            //var inviteVC = vcWithID("InviteParentsVC") as! InviteParentsVC
            //inviteVC.carpool = carpoolsDataSource[indexPath.row]
            //navigationController?.pushViewController(inviteVC, animated: true)
            
            let vc = vcWithID("VolunteerVC") as! VolunteerVC
            vc.carpool = carpoolsDataSource[indexPath.row]
            vc.fromCarpoolList = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func configCarpoolCell(ip: NSIndexPath, _ model: CarpoolModel) -> CarpoolListCell {
        let cell = tableView.cellWithID("CarpoolListCell", ip) as! CarpoolListCell
        cell.loadModel(model)
        return cell
    }
    
    @IBAction func menuButtonClick(sender: UIButton) {
        self.navigationController?.viewDeckController.toggleLeftViewAnimated(true)
    }
    
    @IBAction func createButtonClicked(sender: UIButton) {
        let vc = vcWithID("BasicInfoVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchDataAndReloadTableView() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getCarpools { (success, errorStr) -> () in
            self.refreshControl.endRefreshing()
            LoadingView.dismiss()
            if success {
                InvitationModel.checkInvitations()
                self.generateTableDataAndReload()
            } else {
                self.showAlert("Failed to update carpools", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

    func generateTableDataAndReload() {
        carpoolsDataSource = userManager.carpools.sort { (left : CarpoolModel, right : CarpoolModel) -> Bool in
            if left.startDate == nil || right.startDate == nil { return false}
            return left.startDate!.isLessThanDate(right.startDate!)
        }
        invitesDataSource = UserManager.sharedInstance.invitations
        tableView.reloadData()
    }
}


// MARK: Invitations

extension CarpoolListVC {

    func configCarpoolInviteCell(ip: NSIndexPath, _ model: InvitationModel) -> CarpoolInviteCell {
        let cell = tableView.cellWithID("CarpoolInviteCell", ip) as! CarpoolInviteCell
        cell.invitation = model
        cell.onAccept = self.onViewInvitation
        cell.onDecline = self.onDeclineInvitation
        cell.refreshContent()
        return cell
   }

    func onViewInvitation(invitation: InvitationModel) {
        let vc = vcWithID("InviteConfirmVC") as! InviteConfirmVC
        vc.invitation = invitation
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func onDeclineInvitation(invitation: InvitationModel) {
        LoadingView.showWithMaskType(.Black)
        invitation.decline() { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                onMainThread() {
                    self.generateTableDataAndReload()
                }
            } else {
                self.showAlert("Failed to decline carpool", messege: errorStr, cancleTitle: "OK")
            }
        }
    }

}
