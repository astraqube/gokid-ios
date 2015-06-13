//
//  TeamAccountVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TeamAccountVC: UICollectionViewController {
    
    var collectionViewData = [TeamMemberModel]()
    var um = UserManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        prepareAndLoadCollectionView()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your Team")
        setNavBarLeftButtonTitle("Menu", action: "menuButtonClick")
    }
    
    func prepareAndLoadCollectionView() {
        collectionViewData = [TeamMemberModel]()
        if um.userLoggedIn {
            var userData = TeamMemberModel()
            userData.cellType = .EditUser
            userData.phoneNUmber = um.userPhoneNumber
            userData.role = "You"
            userData.firstName = um.userFirstName
            userData.lastName = um.userLastName
            collectionViewData.append(userData)
            
            addTeamMembersInfo()
            
            var addMember = TeamMemberModel()
            addMember.cellType = .AddMember
            collectionViewData.append(addMember)
        } else {
            var addUser = TeamMemberModel()
            addUser.cellType = .AddUser
            collectionViewData.append(addUser)
        }
        collectionView?.reloadData()
    }
    
    func addTeamMembersInfo() {
        
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
        return collectionViewData.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var model = collectionViewData[indexPath.row]
        if model.cellType == .AddMember {
            var cell = collectionView.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "Add other drivers in you carpool team"
            return cell
        } else if model.cellType == .AddUser {
            var cell = collectionView.cellWithID("AddTeamMemberCell", indexPath) as! AddTeamMemberCell
            cell.contentLabel.text = "Create your profile"
            return cell
        } else if model.cellType == .EditMember || model.cellType == .EditUser {
            var cell = collectionView.cellWithID("TeamAccountCell", indexPath) as! TeamAccountCell
            cell.roleLabel.text = model.role
            cell.nameLabel.text = model.firstName
            return cell
        } else {
            println("Unknow Cell Type")
            return UICollectionViewCell()
        }
    }
    
    // MARK: UICollectionViewDelegate
    // --------------------------------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var model = collectionViewData[indexPath.row]
        if model.cellType == .AddMember || model.cellType == .EditMember || model.cellType == .AddUser {
            var vc = vcWithID("AddTeamMemberVC") as! AddTeamMemberVC
            vc.sourceCellType = model.cellType
            vc.sourceCellIndex = indexPath.row
            vc.model = model
            vc.doneButtonHandler = addMemberDone
            vc.removeButtonHandler = removeMember
            navigationController?.pushViewController(vc, animated: true)
        } else if model.cellType == .EditUser {
            var vc = vcWithID("MemberProfileVC")
            navigationController?.pushViewController(vc, animated: true)
        } else {
            println("Unknow Cell Type")
        }
    }
    
    // MARK: Handle Team account Edit/Add/Delete
    // --------------------------------------------------------------------------------------------
    
    func addMemberDone(vc: AddTeamMemberVC) {
        var model = modelFromAddTeamMemberVC(vc)
        if vc.sourceCellType == .AddUser {
            model.cellType = .EditUser
            var addMember = TeamMemberModel()
            addMember.cellType = .AddMember
            collectionViewData = [model, addMember]
        } else if vc.sourceCellType == .AddMember {
            model.cellType = .EditMember
            collectionViewData.insert(model, atIndex: collectionViewData.count-1)
        } else if vc.sourceCellType == .EditMember {
            var row = vc.sourceCellIndex
            model.cellType = .EditMember
            collectionViewData[row] = model
        }
        collectionView?.reloadData()
    }
    
    func removeMember(vc: AddTeamMemberVC) {
        var row = vc.sourceCellIndex
        collectionViewData.removeAtIndex(row)
        collectionView?.reloadData()
    }
    
    func modelFromAddTeamMemberVC(vc :AddTeamMemberVC) -> TeamMemberModel {
        var model = TeamMemberModel()
        model.firstName = vc.firstNameTextField.text!
        model.lastName = vc.lastNameTextField.text!
        model.role = vc.roleButton.titleLabel!.text!
        model.phoneNUmber = vc.phoneNumberTextField.text!
        return model
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }
}
