//
//  ContactCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    var person: Person!

    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkImageView.setRounded()
        checkImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        checkImageView.layer.borderWidth = 2.0
    }

    func loadPerson(p: Person) {
        person = p

        phoneNumLabel.text = person.contactDisplay
        nameLabel.text = person.fullName

        if person.selected {
            checkImageView.backgroundColor = UIColor.lightGrayColor()
        } else {
            checkImageView.backgroundColor = UIColor.clearColor()
        }
    }
}
