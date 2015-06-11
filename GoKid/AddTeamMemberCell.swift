//
//  AddTeamMemberCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class AddTeamMemberCell: UICollectionViewCell {
    
  @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 5.0
    }
}
