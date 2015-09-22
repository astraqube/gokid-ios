//
//  TeamAccountVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TeamAccountVC: BaseVC {
    
    @IBOutlet weak var menuButton: UIButtonBadged!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource = [TeamMemberModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        registerNotification()
        prepareAndLoadTeamMemberCollectionView()
        registerForNotification("invitationsUpdated", action: "setNotificationsBadge")
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

    func setNotificationsBadge() {
        menuButton.setBadge(InvitationModel.InvitationCount)
    }

    func setupNavBar() {
        let gr = UITapGestureRecognizer(target: self, action: "navBarTapped")
        subtitleLabel.addGestureRecognizer(gr)
        subtitleLabel.userInteractionEnabled = true
        refreshHomeAddress()
    }
    
    func refreshHomeAddress() {
        if userManager.userHomeAdress != "" {
            self.subtitleLabel.text = userManager.userHomeAdress
        } else {
            self.subtitleLabel.text = "Home Address"
        }
    }
    
    func registerNotification() {
        registerForNotification("NavigationBarSubtitleTapped", action: "navBarTapped")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    override func leftNavButtonTapped() {
        viewDeckController.toggleLeftView()
    }
    
    func navBarTapped() {
        if userManager.userLoggedIn {
            let vc = vcWithID("PlacePickerVC") as! PlacePickerVC
            vc.teamVC = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func setHomeAddress(address1: String, address2: String) {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateTeamAddress(address1, address2: address2) { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                onMainThread() {
                    self.refreshHomeAddress()
                }
            } else {
                self.showAlert("Fail to update home address", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    // MARK: CollectionView DataSource
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cv = collectionView
        let model = dataSource[indexPath.row]
        if model.cellType == .AddMember {
            let cell = cv.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "add additional team member"
            return cell
        } else if model.cellType == .AddUser {
            let cell = cv.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "Create your profile"
            return cell
        } else if model.cellType == .EditMember {
            let cell = cv.cellWithID("TeamAccountCell", indexPath) as! TeamAccountCell
            cell.roleLabel.text = model.role
            cell.nameLabel.text = model.firstName
            imageManager.setImageToView(cell.profileImageView, urlStr: model.thumURL)
            return cell
        } else if model.cellType == .EditUser {
            let cell = cv.cellWithID("TeamAccountCell", indexPath) as! TeamAccountCell
            cell.roleLabel.text = "You"
            cell.nameLabel.text = model.firstName
            imageManager.setImageToView(cell.profileImageView, urlStr: model.thumURL)
            return cell
        } else {
            print("Unknow Cell Type", terminator: "")
            return UICollectionViewCell()
        }
    }
    
    // MARK: UICollectionViewDelegate
    // --------------------------------------------------------------------------------------------
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model = dataSource[indexPath.row]
        let cellType = model.cellType
        if cellType == .AddMember || cellType == .EditMember {
            let vc = vcWithID("MemberProfileVC") as! MemberProfileVC
            if model.cellType == .AddMember { vc.model = TeamMemberModel() }
            else { vc.model = model }
            vc.sourceCellIndex = indexPath.row
            vc.sourceCellType = cellType
            vc.doneButtonHandler = addMemberDone
            vc.removeButtonHandler = removeMember
            navigationController?.pushViewController(vc, animated: true)
        } else if cellType == .AddUser || cellType == .EditUser {
            let vc = vcWithID("MemberProfileVC") as! MemberProfileVC
            vc.model = model
            vc.sourceCellType = cellType
            vc.sourceCellIndex = indexPath.row
            vc.doneButtonHandler = memberProfileEditDone
            vc.removeButtonHandler = removeMember
            navigationController?.pushViewController(vc, animated: true)
        } else {
            print("Unknow Cell Type", terminator: "")
        }
    }
    
    // MARK: Handle Team account Edit/Add/Delete
    // --------------------------------------------------------------------------------------------
    
    func addMemberDone(vc: MemberProfileVC) {
        let model = vc.model
        if vc.sourceCellType == .AddMember {
            model.cellType = .EditMember
            dataSource.insert(model, atIndex: dataSource.count-1)
        } else if vc.sourceCellType == .EditMember {
            let row = vc.sourceCellIndex
            model.cellType = .EditMember
            dataSource[row] = model
        }
        collectionView?.reloadData()
    }
    
    func memberProfileEditDone(vc: MemberProfileVC) {
        let model = UserManager.sharedInstance.info
        if vc.sourceCellType == .AddUser {
            prepareAndLoadTeamMemberCollectionView()
        } else if vc.sourceCellType == .EditUser {
            let row = vc.sourceCellIndex
            dataSource[row] = model
        }
        collectionView?.reloadData()
    }
    
    func removeMember(vc: MemberProfileVC) {
        let row = vc.sourceCellIndex
        let model = dataSource[row]
        dataManager.deleteTeamMember(model.permissionID) { (success, errorStr) in
            if success {
                vc.navigationController?.popViewControllerAnimated(true)
            } else {
                self.showAlert("Failed to delete member", messege: errorStr, cancleTitle: "OK")
            }
        }
        dataSource.removeAtIndex(row)
        collectionView?.reloadData()
    }
    
    // MARK: Data Layer Method
    // --------------------------------------------------------------------------------------------
    
    func prepareAndLoadTeamMemberCollectionView() {
        dataSource = [TeamMemberModel]()
        if userManager.userLoggedIn {
            dataSource.append(userManager.info)
            addTeamMembersInfoAndLoadCollectionView()
        } else {
            let addUser = TeamMemberModel()
            addUser.cellType = .AddUser
            dataSource.append(addUser)
            collectionView?.reloadData()
        }
    }
    
    func addTeamMembersInfoAndLoadCollectionView() {
        LoadingView.showWithMaskType(.Black)
        dataManager.getTeamMembersOfTeam { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.dataSource.appendArr(self.userManager.teamMembers)
                self.appendAddMemberCell()
                self.reloadCollectionViewOnMainThread()
                self.refreshHomeAddress()
            } else {
                self.showAlert("Alert", messege: errorStr, cancleTitle: "OK")
            }
        }
    }
    
    func reloadCollectionViewOnMainThread() {
        onMainThread() {
            self.collectionView?.reloadData()
        }
    }
    
    func appendAddMemberCell() {
        let addMemberCell = TeamMemberModel()
        addMemberCell.cellType = .AddMember
        dataSource.append(addMemberCell)
    }
    
    // MARK: End Editing
    // --------------------------------------------------------------------------------------------

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}
