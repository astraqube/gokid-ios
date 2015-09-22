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
        profileImageView.backgroundColor = UIColor.grayColor()
        profileImageView.setRounded()
        
        layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        layer.borderColor = rgb(186, g: 210, b: 182).CGColor
        layer.cornerRadius = 3.0
    }

}
