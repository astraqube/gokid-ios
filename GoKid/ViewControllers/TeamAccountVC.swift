//
//  TeamAccountVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TeamAccountVC: UICollectionViewController {
    
    var dataSource = [TeamMemberModel]()
    var im = ImageManager.sharedInstance
    var um = UserManager.sharedInstance
    var dm = DataManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        prepareAndLoadTeamMemberCollectionView()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your Team")
        setNavBarLeftButtonTitle("Menu", action: "menuButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func menuButtonClick() {
        viewDeckController.toggleLeftView()
    }
    
    
    // MARK: CollectionView DataSource
    // --------------------------------------------------------------------------------------------
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cv = collectionView
        var model = dataSource[indexPath.row]
        if model.cellType == .AddMember {
            var cell = cv.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "Add other drivers in you carpool team"
            return cell
        } else if model.cellType == .AddUser {
            var cell = cv.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "Create your profile"
            return cell
        } else if model.cellType == .EditMember {
            var cell = cv.cellWithID("TeamAccountCell", indexPath) as! TeamAccountCell
            cell.roleLabel.text = model.role
            cell.nameLabel.text = model.firstName
            im.setImageToView(cell.profileImageView, urlStr: model.thumURL)
            return cell
        } else if model.cellType == .EditUser {
            var cell = cv.cellWithID("TeamAccountCell", indexPath) as! TeamAccountCell
            cell.roleLabel.text = "You"
            cell.nameLabel.text = model.firstName
            im.setImageToView(cell.profileImageView, urlStr: model.thumURL)
            return cell
        } else {
            println("Unknow Cell Type")
            return UICollectionViewCell()
        }
    }
    
    // MARK: UICollectionViewDelegate
    // --------------------------------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var model = dataSource[indexPath.row]
        if model.cellType == .AddMember || model.cellType == .EditMember {
            var vc = vcWithID("AddTeamMemberVC") as! AddTeamMemberVC
            vc.model = model
            vc.sourceCellIndex = indexPath.row
            vc.sourceCellType = model.cellType
            vc.doneButtonHandler = addMemberDone
            vc.removeButtonHandler = removeMember
            navigationController?.pushViewController(vc, animated: true)
        } else if model.cellType == .AddUser || model.cellType == .EditUser {
            var vc = vcWithID("MemberProfileVC") as! MemberProfileVC
            vc.model = model
            vc.sourceCellType = model.cellType
            vc.sourceCellIndex = indexPath.row
            vc.doneButtonHandler = memberProfileEditDone
            navigationController?.pushViewController(vc, animated: true)
        } else {
            println("Unknow Cell Type")
        }
    }
    
    // MARK: Handle Team account Edit/Add/Delete
    // --------------------------------------------------------------------------------------------
    
    func addMemberDone(vc: AddTeamMemberVC) {
        var model = modelFromAddTeamMemberVC(vc)
        if vc.sourceCellType == .AddMember {
            model.cellType = .EditMember
            dataSource.insert(model, atIndex: dataSource.count-1)
        } else if vc.sourceCellType == .EditMember {
            var row = vc.sourceCellIndex
            model.cellType = .EditMember
            dataSource[row] = model
        }
        collectionView?.reloadData()
    }
    
    func memberProfileEditDone(vc: MemberProfileVC) {
        var model = UserManager.sharedInstance.info
        if vc.sourceCellType == .AddUser {
            prepareAndLoadTeamMemberCollectionView()
        } else if vc.sourceCellType == .EditUser {
            var row = vc.sourceCellIndex
            dataSource[row] = model
        }
        collectionView?.reloadData()
    }
    
    func removeMember(vc: AddTeamMemberVC) {
        var row = vc.sourceCellIndex
        var model = dataSource[row]
        dm.deleteTeamMember(model.id) { (success, errorStr) in
            if !success {
                self.showAlert("Failed to delete member", messege: errorStr, cancleTitle: "OK")
            }
        }
        dataSource.removeAtIndex(row)
        collectionView?.reloadData()
    }
    
    func modelFromAddTeamMemberVC(vc :AddTeamMemberVC) -> TeamMemberModel {
        var model = TeamMemberModel()
        model.phoneNumber = vc.phoneNumberTextField.text!
        model.firstName = vc.firstNameTextField.text!
        model.role = vc.roleButton.titleLabel!.text!
        model.lastName = vc.lastNameTextField.text!
        return model
    }
    
    // MARK: Data Layer Method
    // --------------------------------------------------------------------------------------------
    
    func prepareAndLoadTeamMemberCollectionView() {
        dataSource = [TeamMemberModel]()
        if um.userLoggedIn {
            dataSource.append(um.info)
            addTeamMembersInfoAndLoadCollectionView()
        } else {
            var addUser = TeamMemberModel()
            addUser.cellType = .AddUser
            dataSource.append(addUser)
            collectionView?.reloadData()
        }
    }
    
    func addTeamMembersInfoAndLoadCollectionView() {
        LoadingView.showWithMaskType(.Black)
        dm.getTeamMembersOfTeam { (success, errorStr) in
            LoadingView.dismiss()
            if success {
                self.dataSource.appendArr(self.um.teamMembers)
                self.appendAddMemberCell()
                self.reloadCollectionViewOnMainThread()
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
        var addMemberCell = TeamMemberModel()
        addMemberCell.cellType = .AddMember
        dataSource.append(addMemberCell)
    }
    
    // MARK: End Editing
    // --------------------------------------------------------------------------------------------
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
}
