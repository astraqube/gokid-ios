//
//  CarpoolListCell.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/14/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CarpoolListCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    /**
    The in-order collection of `CallendarUserImageView`
    
    Iterate through them. Add data you have. Clear data you don't.
    
    Set hidden the ones there are no riders for.
    */
    @IBOutlet var pickupImageCollection : [CalendarUserImageView]!
}
