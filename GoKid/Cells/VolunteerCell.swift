//
//  VolunteerCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerCell: UITableViewCell {
    
    @IBOutlet weak var driverTitleLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var poolTypeLabel: UILabel?
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var driverImageView: UIImageView!
    var checkButtonHandler: ((VolunteerCell, UIButton)->(Void))?

    var occurrenceModel: OccurenceModel!
    var poolType: String!

    var holdTime: NSTimer!

    var presenter: UIViewController?

    let dataManager = DataManager.sharedInstance

    var isVolunteeredByMe = false

    override func awakeFromNib() {
        super.awakeFromNib()
        checkButton.setRounded()
        checkButton.addTarget(self, action: Selector("holdRelease:"), forControlEvents: UIControlEvents.TouchUpInside);
        checkButton.addTarget(self, action: Selector("holdDown:"), forControlEvents: UIControlEvents.TouchDown)
    }
    
    func loadModel(model: OccurenceModel!) {
        occurrenceModel = model
        timeLabel?.text = model.poolTimeStringWithSpace()

        poolType = model.poolType == "pickup" ? "Drive to Event" : "Return from Event"
        poolTypeLabel?.text = poolType

        if model.taken {
            ImageManager.sharedInstance.setImageToView(driverImageView, urlStr: model.poolDriverImageUrl)
            driverTitleLabel?.text = model.poolDriverName
        } else {
            driverImageView.image = UIImage(named: "checkCirc")
            driverTitleLabel?.text = "Volunteer to Drive"
        }

        if model.volunteer != nil {
            isVolunteeredByMe = model.volunteer!.id == UserManager.sharedInstance.info.userID
        } else {
            isVolunteeredByMe = false
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
        if occurrenceModel.taken && isVolunteeredByMe {
            unRegisterVolunteerForCell()
        } else{
            registerVolunteerForCell()
        }
    }

    func unRegisterVolunteerForCell() {
        if occurrenceModel.volunteer!.id == UserManager.sharedInstance.info.userID {
            LoadingView.showWithMaskType(.Black)
            dataManager.unregisterForOccurence(occurrenceModel) { (success, errStr) in
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
        dataManager.registerForOccurence(occurrenceModel) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    self.loadModel(self.occurrenceModel)
                }
            }
        }
    }

    func batchAction(type: String!) {
        LoadingView.showWithMaskType(.Black)
        let call = occurrenceModel.taken && isVolunteeredByMe ? dataManager.unregisterForCarpool : dataManager.registerForCarpool
        call(occurrenceModel.carpool, type: type) { (success, error) -> () in
            LoadingView.dismiss()
            if success {
                self.postNotification("refreshVolunteerCells")
            }
        }
    }

    func showButtonActionList() {
        holdTime.invalidate()

        if !occurrenceModel.carpool.isOwner && occurrenceModel.taken && !isVolunteeredByMe {
            // not allowed any action
            return
        }

        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let actionStr = occurrenceModel.taken && isVolunteeredByMe ? "Unvolunteer" : "Volunteer"

        let actionOnce = UIAlertAction(title: actionStr, style: .Default) { (_) in
            self.checkButtonClick()
        }

        let day = occurrenceModel.occursAt!.weekDayFullString()
        let actionDay = UIAlertAction(title: "\(actionStr) Every \(day)", style: .Default) { (_) in
            self.batchAction("all_\(day.lowercaseString)")
        }

        let actionAllType = UIAlertAction(title: "\(actionStr) All \(poolType)", style: .Default) { (_) in
            self.batchAction("all_\(self.occurrenceModel.poolType.lowercaseString)")
        }

        let actionEveryday = UIAlertAction(title: "\(actionStr) Everyday", style: .Default) { (_) in
            self.batchAction("all")
        }

        let actionCancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        menu.addAction(actionOnce)
        menu.addAction(actionDay)
        menu.addAction(actionAllType)
        menu.addAction(actionEveryday)

        if !occurrenceModel.taken && occurrenceModel.carpool.isOwner {
            let actionMember = UIAlertAction(title: "Assign Team Member", style: .Default) { (_) in
                self.pickTeamMember()
            }
            menu.addAction(actionMember)
        }

        menu.addAction(actionCancel)

        presenter?.presentViewController(menu, animated: true, completion: nil)
    }

    func showAlert(title: String, messege: String) {
        onMainThread() {
            let alertView = UIAlertView(title: title, message: messege, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }

    func pickTeamMember() {
        dataManager.getTeamMembersOfTeam { (success, error) in
            if success {
                let members = UserManager.sharedInstance.teamMembers.filter { (m) -> Bool in
                    return m.role != RoleTypeChild
                }
                if !members.isEmpty {

                    let menu = UIAlertController(title: "Choose a Driver", message: nil, preferredStyle: .Alert)

                    menu.addAction(UIAlertAction(title: "Myself", style: .Default, handler: { (alert: UIAlertAction) in
                        self.registerVolunteerForCell()
                    }))

                    for member in members {
                        menu.addAction(UIAlertAction(title: member.fullName, style: .Default, handler: { (alert: UIAlertAction) in
                            self.assignTeamMember(member)
                        }))
                    }

                    menu.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

                    self.presenter?.presentViewController(menu, animated: true, completion: nil)

                } else {
                    self.presenter?.showAlert("Sorry", messege: "You don't have other drivers in your team yet", cancleTitle: "OK")
                }
            } else {
                self.presenter?.showAlert("Error", messege: error, cancleTitle: "OK")
            }
        }
    }

    func assignTeamMember(member: TeamMemberModel) {
        LoadingView.showWithMaskType(.Black)
        dataManager.registerForOccurence(occurrenceModel, member: member) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    self.loadModel(self.occurrenceModel)
                }
            }
        }
    }

}
