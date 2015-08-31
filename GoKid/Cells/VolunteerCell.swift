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

    var holdTime: NSTimer!

    var presenter: UIViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.setRounded()
        checkButton.addTarget(self, action: Selector("holdRelease:"), forControlEvents: UIControlEvents.TouchUpInside);
        checkButton.addTarget(self, action: Selector("holdDown:"), forControlEvents: UIControlEvents.TouchDown)
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

    func holdDown(sender: UIButton) {
        holdTime = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "showButtonActionList", userInfo: nil, repeats: false)
    }

    func holdRelease(sender: UIButton) {
        if holdTime.valid {
            checkButtonClick()
        }
    }

    func checkButtonClick() {
        holdTime.invalidate()
        if occurrenceModel.taken {
            unRegisterVolunteerForCell()
        } else{
            registerVolunteerForCell()
        }
    }

    func unRegisterVolunteerForCell() {
        if occurrenceModel.volunteer!.id == UserManager.sharedInstance.info.userID {
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

    func showButtonActionList() {
        holdTime.invalidate()
        if occurrenceModel.taken && occurrenceModel.volunteer!.id != UserManager.sharedInstance.info.userID {
            return
        }
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let actionStr = occurrenceModel.taken ? "Unvolunteer" : "Volunteer"

        let actionOnce = UIAlertAction(title: actionStr, style: .Default) { (_) in
            self.checkButtonClick()
        }
        
        let actionDay = UIAlertAction(title: "\(actionStr) Every \(occurrenceModel.occursAt!.weekDayFullString())", style: .Default) { (_) in }
        let actionAllType = UIAlertAction(title: "\(actionStr) All \(occurrenceModel.poolType.capitalizedString)", style: .Default) { (_) in }
        let actionEveryday = UIAlertAction(title: "\(actionStr) Everyday", style: .Default) { (_) in }

        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }

        menu.addAction(actionOnce)
        menu.addAction(actionDay)
        menu.addAction(actionAllType)
        menu.addAction(actionEveryday)
        menu.addAction(actionCancel)

        presenter?.presentViewController(menu, animated: true, completion: nil)
    }

}
