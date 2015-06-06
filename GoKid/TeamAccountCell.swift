//
//  TeamAccountCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TeamAccountCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    override func awakeFromNib() {
        self.profileImageView.backgroundColor = UIColor.grayColor()
        self.profileImageView.layer.cornerRadius = profileImageView.w/2.0
        self.profileImageView.clipsToBounds = true
    }

}
