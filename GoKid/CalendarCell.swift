//
//  CalendarCell.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

import UIKit

class CalendarCell: VolunteerCell {
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var pickupIcon: UILabel!
    @IBOutlet weak var dropoffIcon: UILabel!

    @IBOutlet weak var optedOutLabel: UILabel!

    /**
    The in-order collection of `CallendarUserImageView`

    Iterate through them. Add data you have. Clear data you don't.

    Set hidden the ones there are no riders for.
    */
    @IBOutlet var pickupImageCollection : [CalendarUserImageView]!

    override func loadModel(model: OccurenceModel!) {
        super.loadModel(model)

        nameLabel.text = model.poolname

        if model.occurrenceType == .Dropoff {
            pickupIcon.hidden = true
            dropoffIcon.hidden = false
        } else {
            pickupIcon.hidden = false
            dropoffIcon.hidden = true
        }

        for (index, riderImageView) in pickupImageCollection.enumerate() {
            let rider : RiderModel? = (model.riders.count > index) ? model.riders[index] : nil
            riderImageView.hidden = rider == nil
            if rider != nil {
                riderImageView.setAvatar(rider!.fullName, imageURL: rider!.thumURL)
            }
        }

        let myRiders = model.riders.filter { (r: RiderModel) -> Bool in
            return r.isInMyTeam
        }

        optedOutLabel.hidden = myRiders.count > 0
    }

}
