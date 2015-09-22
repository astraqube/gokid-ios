//
//  InviteesVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 9/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class InviteesVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

    var carpool: CarpoolModel!

    @IBOutlet var tableView: UITableView!
    var dataSource = [InvitationModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarColorDark()

        // FIXME: temporary support for CarpoolEditVC's invocation
        if carpool == nil {
            carpool = userManager.currentCarpoolModel
        }

        self.subtitleLabel?.text = carpool.descriptionString
        loadInvites()
    }

    override func leftNavButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }

    func loadInvites() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getCarpoolInvites(carpool) { (success, error, invites) in
            LoadingView.dismiss()
            if success {
                self.dataSource = invites as! [InvitationModel]
                self.tableView.reloadData()
            } else {
                self.showAlert("Error", messege: error, cancleTitle: "OK")
            }
        }
    }

    // MARK: Table Datasource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row] as InvitationModel
        let cell = tableView.dequeueReusableCellWithIdentifier("InviteeCell", forIndexPath: indexPath) 
        cell.textLabel?.text = model.phoneNum
        cell.detailTextLabel?.text = model.status.captialName()
        return cell
    }

}
