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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var pickupIcon: UILabel!
    @IBOutlet weak var dropoffIcon: UILabel!

    @IBOutlet weak var optedOutLabel: UILabel!

    /**
    Callback called when someone taps on `profileImageView`. Set to recieve callbacks.
    
    Ensure all variables captured are weak.
    */
    var onProfileImageViewTapped : (()->(Void))?
    
    /**
    The in-order collection of `CallendarUserImageView`

    Iterate through them. Add data you have. Clear data you don't.

    Set hidden the ones there are no riders for.
    */
    @IBOutlet var pickupImageCollection : [CalendarUserImageView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "profileImageViewTappped"))
    }
    
    func profileImageViewTappped() {
        onProfileImageViewTapped?()
    }
}
