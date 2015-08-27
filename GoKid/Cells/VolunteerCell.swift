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

    var occurrenceModel: OccurenceModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.setRounded()
    }
    
    @IBAction func checkButtonClick(sender: UIButton) {
        if occurrenceModel.taken {
            unRegisterVolunteerForCell()
        } else{
            registerVolunteerForCell()
        }
    }

    func loadModel(model: OccurenceModel!) {
        occurrenceModel = model
        timeLabel.text = model.poolTimeStringWithSpace()

        if model.poolType == "pickup" {
            poolTypeLabel.text = "Drive to Event"
        } else {
            poolTypeLabel.text = "Return from Event"
        }

        if model.taken {
            ImageManager.sharedInstance.setImageToView(driverImageView, urlStr: model.poolDriverImageUrl)
            driverTitleLabel.text = model.poolDriverName
        } else {
            driverImageView.image = UIImage(named: "checkCirc")
            driverTitleLabel.text = "Volunteer to Drive"
        }
    }

    func unRegisterVolunteerForCell() {
        LoadingView.showWithMaskType(.Black)
        DataManager.sharedInstance.unregisterForOccurence(occurrenceModel) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    self.loadModel(self.occurrenceModel)
                }
            }
        }
    }

    func registerVolunteerForCell() {
        LoadingView.showWithMaskType(.Black)
        DataManager.sharedInstance.registerForOccurence(occurrenceModel) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    self.loadModel(self.occurrenceModel)
                }
            }
        }
    }

}
