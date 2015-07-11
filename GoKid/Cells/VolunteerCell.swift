//
//  VolunteerCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerCell: UITableViewCell {
    
    @IBOutlet weak var driverTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var poolTypeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var driverImageView: UIImageView!
    var checkButtonHandler: ((VolunteerCell, UIButton)->(Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.setRounded()
    }
    
    @IBAction func checkButtonClick(sender: UIButton) {
        checkButtonHandler?(self, sender)
    }
}
