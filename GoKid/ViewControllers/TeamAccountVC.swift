//
//  TeamAccountVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

let reuseIdentifier = "TeamAccountCell"

class TeamAccountVC: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        collectionView?.delegate = self
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
        return 40
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? TeamAccountCell
        return cell!
    }
    
    // MARK: UICollectionViewDelegate
    // --------------------------------------------------------------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var vc = vcWithID("MemberProfileVC")
        navigationController?.pushViewController(vc, animated: true)
    }
}
