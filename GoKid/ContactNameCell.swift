//
//  ContactNameCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/7/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class ContactNameCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cancleButton: UIButton!
    var cancleButtonHandler: ((ContactNameCell)->())?
    
    @IBAction func cancleButtonClick(sender: UIButton) {
        cancleButtonHandler?(self)
    }
}
