//
//  CalendarCellAddCell.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

import UIKit

class CalendarAddCell: UITableViewCell {

    @IBOutlet weak var borderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderImageView.layer.borderColor = ColorManager.sharedInstance.darkGrayColor.CGColor
        borderImageView.layer.borderWidth = 4.0
        borderImageView.layer.cornerRadius = 2.0
    }
}
