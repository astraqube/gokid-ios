//
//  FrequencyCell.swift
//  
//
//  Created by Bingwen Fu on 6/28/15.
//
//

import UIKit

class FrequencyCell: UITableViewCell {

    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setChecked(checked: Bool) {
        if checked {
            checkImageView.backgroundColor = UIColor.grayColor()
        } else {
            checkImageView.backgroundColor = UIColor.clearColor()
        }
    }
}
