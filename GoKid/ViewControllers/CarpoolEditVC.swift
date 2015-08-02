//
//  CarpoolEditVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 8/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CarpoolEditVC: BaseFormVC {

    var occurrence : OccurenceModel!

    private enum Tags : String {
        case EventLocation = "Event Location"
        case InvitePanel = "Invite Parents"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = userManager.currentCarpoolDescription()
        self.subtitleLabel.text = userManager.currentCarpoolDescription()
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.InvitePanel.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.InvitePanel.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.action.viewControllerStoryboardId = "InviteParentsVC"
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.EventLocation.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.EventLocation.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.action.viewControllerStoryboardId = "LocationInputVC"
        row.value = self.occurrence.eventLocation.name
        section.addFormRow(row)

        form.addFormSection(section)

        if self.occurrence.riders.count > 0 {

            section = XLFormSectionDescriptor.formSectionWithTitle("\(self.occurrence.occurrenceType.rawValue) Locations") as XLFormSectionDescriptor

            for rider in self.occurrence.riders {

                row = XLFormRowDescriptor(tag: rider.riderID.description, rowType: XLFormRowDescriptorTypeSelectorPush, title: rider.fullName)
                row.cellConfig["textLabel.font"] = fontLabel
                row.cellConfig["textLabel.color"] = colorLabel
                row.cellConfig["detailTextLabel.font"] = fontValue
                row.cellConfig["detailTextLabel.color"] = colorLabel
                row.action.viewControllerStoryboardId = "LocationInputVC"

                if self.occurrence.occurrenceType == .Pickup {
                    row.value = rider.pickupLocation.name
                } else {
                    row.value = rider.dropoffLocation.name
                }

                section.addFormRow(row)
            }

            form.addFormSection(section)
        }

        self.form = form
        self.form.delegate = self
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.EventLocation.rawValue {
            self.updateEventLocation(newValue as! String)

        } else if formRow.tag.toInt() != nil {
            // FIXME: If the form supports fields other than event_location, pickup_address, and dropoff_address
            // this may have to be changed to something better targeted
            self.updateRiderLocation(formRow.tag.toInt(), address: newValue as! String)
        }
    }

    private func updateEventLocation(address: String) {
        LoadingView.showWithMaskType(.Black)
        Location.geoCodeAddress(address) { (lon, lat) in
            let location = Location(name: address, long: lon, lati: lat)
            self.dataManager.updateOccurrenceLocation(self.occurrence.occurenceID, location: location) { (success, error) in
                LoadingView.dismiss()
                if !success && error != "" {
                    self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
                } else {
                    self.occurrence.eventLocation = location
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func updateRiderLocation(riderID: Int!, address: String) {
        LoadingView.showWithMaskType(.Black)
        Location.geoCodeAddress(address) { (lon, lat) in
            let location = Location(name: address, long: lon, lati: lat)

            var rider = RiderModel()
            rider.riderID = riderID

            if self.occurrence.occurrenceType == .Pickup {
                rider.pickupLocation = location
            } else {
                rider.dropoffLocation = location
            }

            self.dataManager.updateRiderInCarpool(rider, carpoolID: self.occurrence.carpoolID) { (success, error, riderModel) in
                LoadingView.dismiss()
                if !success && error != "" {
                    self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
                } else {
                    let _rider = riderModel as! RiderModel
                    let index = find(self.occurrence.riders, _rider)
                    self.occurrence.riders.removeAtIndex(index!)
                    self.occurrence.riders.insert(_rider, atIndex: index!)
                    self.tableView.reloadData()
                }
            }
        }
    }

}
