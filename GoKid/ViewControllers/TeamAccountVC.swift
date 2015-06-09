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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
    }
    
    func setupNavBar() {
        setNavBarTitle("Your Team")
        setNavBarLeftButtonTitle("Menu", action: "menuButtonClick")
    }
    
    func setupCollectionView() {
        var um = UserManager.sharedInstance
        collectionViewData = um.teamMembers
        collectionView?.reloadData()
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
        // last cell is add member
        return collectionViewData.count + 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == collectionViewData.count {
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddTeamMemberCell", forIndexPath: indexPath) as? AddTeamMemberCell
            return cell!
        }
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("TeamAccountCell", forIndexPath: indexPath) as? TeamAccountCell
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    // --------------------------------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == collectionViewData.count {
            var vc = vcWithID("MemberProfileVC")
            presentViewController(vc, animated: true, completion: nil)
            return
        }
        var vc = vcWithID("MemberProfileVC")
        navigationController?.pushViewController(vc, animated: true)
        //presentViewController(vc, animated: true, completion: nil)
    }
}
