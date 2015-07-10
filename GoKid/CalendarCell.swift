//
//  CalendarCell.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

import UIKit

class CalendarCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var pickupIcon: UILabel!
    @IBOutlet weak var dropoffIcon: UILabel!
    
    /**
    The in-order collection of `CallendarUserImageView`

    Iterate through them. Add data you have. Clear data you don't.

    Set hidden the ones there are no riders for.
    */
    @IBOutlet var pickupImageCollection : [CalendarUserImageView]!
}
