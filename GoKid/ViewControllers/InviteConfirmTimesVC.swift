//
//  InviteConfirmTimesVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 8/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import XLForm

class InviteConfirmTimesVC: BaseFormVC {

    var invitation: InvitationModel!
    var rider: RiderModel!
    var occurrences: [OccurenceModel]!

    private enum Tags : String {
        case ChangeAll = "Change everything below"
        case RideNone = "Not Joining"
        case RideBoth = "Both Pickup & Dropoff"
        case RidePickup = "Pickup Only"
        case RideDropoff = "Dropoff Only"

        static let allRides = [
            RideNone.rawValue, RideBoth.rawValue, RidePickup.rawValue, RideDropoff.rawValue
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleLabel.text = subtitleLabel.text?.replace("XXX", rider.firstName)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func rightNavButtonTapped() {
        let vc = vcWithID("LocationVC") as! LocationVC
        vc.carpool = self.invitation.carpool
        vc.rider = rider
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        var sectionHolder: String!
/*
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.ChangeAll.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: Tags.ChangeAll.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.selectorOptions = Tags.allRides
        section.addFormRow(row)

        form.addFormSection(section)
*/
        for occ in occurrences {

            if sectionHolder != occ.occursAtStr {
                section = XLFormSectionDescriptor.formSectionWithTitle(occ.occursAtStr) as XLFormSectionDescriptor
            }

            row = XLFormRowDescriptor(tag: occ.occurenceID.description, rowType: XLFormRowDescriptorTypeBooleanCheck, title: occ.rideString)
            row.cellConfig["textLabel.font"] = valueFont
            row.cellConfig["textLabel.color"] = labelColor
            row.selectorOptions = Tags.allRides
            row.value = true
            section.addFormRow(row)

            if sectionHolder != occ.occursAtStr {
                form.addFormSection(section)
                sectionHolder = occ.occursAtStr
            }

        }

        self.form = form
        self.form.delegate = self
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.ChangeAll.rawValue {
        } else {
            let occ = occurrences.filter({ (record: OccurenceModel) -> Bool in
                return record.occurenceID == Int(formRow.tag!)
            })
            if (formRow.value as! Bool) == false {
                dataManager.deleteFromOccurenceRiders(rider, occ: occ.first!) { (success, error) in
                    //... do nothing
                }
            } else {
                dataManager.addRiderToOccurrence(rider, occ: occ.first!) { (success, error) in
                    //... do nothing
                }
            }
        }

        self.toggleRightNavButtonState()
    }

}
