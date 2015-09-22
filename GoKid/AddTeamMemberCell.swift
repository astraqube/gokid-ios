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
        layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        layer.borderColor = rgb(186, g: 210, b: 182).CGColor
        layer.cornerRadius = 3.0
    }
}
