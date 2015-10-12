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

    func loadModel(model: CarpoolModel) {
        if model.startDate != nil && model.endDate != nil {
            timeLabel.text = "\(model.startDate!.shortDateString()) - \(model.endDate!.shortDateString())"
        } else {
            // FIXME: wtf is this?
            timeLabel.text = "loading…"
        }

        for (index, riderImageView) in enumerate(pickupImageCollection) {
            let rider : RiderModel? = (model.riders.count > index) ? model.riders[index] : nil
            riderImageView.hidden = rider == nil
            if rider != nil {
                riderImageView.setAvatar(rider!.fullName, imageURL: rider!.thumURL)
            }
        }

        nameLabel.text = model.name

        let CM = ColorManager.sharedInstance
        let theme = model.isOwner ? CM.color456462 : CM.color456462.colorWithAlphaComponent(0.6)
        nameLabel.textColor = theme
        timeLabel.textColor = theme
    }

}
