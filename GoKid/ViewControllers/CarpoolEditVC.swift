//
//  CarpoolEditVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 8/1/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import XLForm

///Allows editing of Occurrences.
///Deleteion of the Carpool or Occurrence pops to root VC of NavController.
///A callback function alerts  changes of the model.
class CarpoolEditVC: BaseFormVC {
    var occurrence : OccurenceModel!
    
    ///This method is called on each update of occurrence but NOT deletion
    var onOccurrenceEdited : ((occurrence: OccurenceModel)->())?
    
    private enum Tags : String {
        case CarpoolName = "Carpool Name"
        case Unauthorized = "You are not authorized to make changes"
        case ChangeTimes = "Change Times"
        case EventLocation = "Event Location"
        case InviteeList = "Invitee List"
        case InvitePanel = "Invite Parents via SMS or Email"
        case DeleteRide = "Delete this Ride"
        case DeleteCarpool = "Delete this Carpool"
    }

    var isCurrentUserAuthorized : Bool {
        // TODO: Waiting on backend to point how Carpool Ownership is determined
        return occurrence.carpool.isOwner
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: temporarily using singleton to pass CarpoolModel
        userManager.currentCarpoolModel = occurrence.carpool
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subtitleLabel.text = occurrence.carpool.descriptionString
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        if !self.isCurrentUserAuthorized {
            section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

            row = XLFormRowDescriptor(tag: Tags.Unauthorized.rawValue, rowType: XLFormRowDescriptorTypeInfo, title: Tags.Unauthorized.rawValue)
            row.cellConfigAtConfigure["backgroundColor"] = colorManager.color2EB56A
            row.cellConfig["textLabel.font"] = labelFont
            row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
            section.addFormRow(row)

            form.addFormSection(section)
        }

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: Tags.CarpoolName.rawValue, rowType: XLFormRowDescriptorTypeText, title: Tags.CarpoolName.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["textField.font"] = valueFont
        row.cellConfig["textField.textColor"] = labelColor
        row.cellConfig["textField.textAlignment"] =  NSTextAlignment.Right.rawValue
        row.cellConfig["textField.enabled"] = false
        row.value = occurrence.carpool.name
        row.disabled = !self.isCurrentUserAuthorized
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.EventLocation.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.EventLocation.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.action.viewControllerStoryboardId = "LocationInputVC"
        row.value = self.occurrence.eventLocation.name
        row.disabled = !self.isCurrentUserAuthorized
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.ChangeTimes.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.ChangeTimes.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.disabled = !self.isCurrentUserAuthorized
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.InvitePanel.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.InvitePanel.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.action.viewControllerStoryboardId = "ContactPickerVC"
        row.disabled = !self.isCurrentUserAuthorized
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: Tags.InviteeList.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.InviteeList.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.action.viewControllerStoryboardId = "InviteesVC"
        row.disabled = !self.isCurrentUserAuthorized
        section.addFormRow(row)

        form.addFormSection(section)

        if self.occurrence.riders.count > 0 {

            section = XLFormSectionDescriptor.formSectionWithTitle("\(self.occurrence.occurrenceType.rawValue) Locations") as XLFormSectionDescriptor

            for rider in self.occurrence.riders {

                row = XLFormRowDescriptor(tag: rider.riderID.description, rowType: XLFormRowDescriptorTypeSelectorPush, title: rider.fullName)
                row.cellConfig["textLabel.font"] = labelFont
                row.cellConfig["textLabel.color"] = labelColor
                row.cellConfig["detailTextLabel.font"] = valueFont
                row.cellConfig["detailTextLabel.color"] = labelColor
                row.action.viewControllerStoryboardId = "LocationInputVC"

                if self.occurrence.occurrenceType == .Pickup {
                    row.value = rider.pickupLocation.name
                } else {
                    row.value = rider.dropoffLocation.name
                }

                row.disabled = !self.isCurrentUserAuthorized
                section.addFormRow(row)
            }

            form.addFormSection(section)
        }

        if self.isCurrentUserAuthorized {
            section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

            row = XLFormRowDescriptor(tag: Tags.DeleteRide.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.DeleteRide.rawValue)
            row.cellConfig["textLabel.font"] = valueFont
            row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
            row.cellConfigAtConfigure["backgroundColor"] = colorManager.colorWarningRed
            row.action.formSelector = "deleteRide:"
            row.disabled = !self.isCurrentUserAuthorized
            section.addFormRow(row)

            row = XLFormRowDescriptor(tag: Tags.DeleteCarpool.rawValue, rowType: XLFormRowDescriptorTypeButton, title: Tags.DeleteCarpool.rawValue)
            row.cellConfig["textLabel.font"] = valueFont
            row.cellConfig["textLabel.color"] = colorManager.colorF9FCF5
            row.cellConfigAtConfigure["backgroundColor"] = colorManager.colorDangerRed
            row.action.formSelector = "deleteCarpool:"
            row.disabled = !self.isCurrentUserAuthorized
            section.addFormRow(row)

            form.addFormSection(section)
        }

        self.form = form
        self.form.delegate = self
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.EventLocation.rawValue {
            self.updateEventLocation(newValue as! String)

        } else if let tagNum = Int(formRow.tag!) {
            // FIXME: This assumes form tag that is Int-based only applies to Rider fields
            self.updateRiderLocation(tagNum, address: newValue as! String)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        let formRow = self.form.formRowAtIndex(indexPath)

        if formRow!.tag == Tags.CarpoolName.rawValue {
            self.editCarpoolName(formRow)
        } else if formRow!.tag == Tags.ChangeTimes.rawValue {
            // Fetch carpool again to get times
            dataManager.getCarpool(self.occurrence.carpoolID, comp: { (success, errorString, model) -> () in
                if success {
                    self.dataManager.getOccurenceOfCarpool2(self.occurrence.carpoolID, comp: { (success2, errorString2, obj2) -> () in
                        if success2 {
                            let carpoolModel = model as! CarpoolModel
                            let vc = vcWithID("EditTimeAndDateFormVC") as! EditTimeAndDateFormVC
                            vc.carpoolModel = carpoolModel
                            vc.occurrences = obj2 as! [OccurenceModel]
                            
                            NSLog("occ = %@", vc.occurrences[0].occursAt!)
                            NSLog("occ = %@", vc.occurrences[1].occursAt!)
                            
                            self.navigationController!.pushViewController(vc, animated: true)
                        }
                    })
                    
                    
                }
            })
        }
    }
    
    func editCarpoolName(fieldCell: XLFormRowDescriptor!) {
        let confirmPrompt = UIAlertController(title: Tags.CarpoolName.rawValue, message: nil, preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.text = fieldCell.value as? String
            textField.placeholder = "Enter a new name"
        }

        confirmPrompt.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        confirmPrompt.addAction(UIAlertAction(title: "Submit", style: .Default, handler: { (alert: UIAlertAction) in
            if let textField = confirmPrompt.textFields?.first as UITextField? {
                self.updateCarpoolName(textField.text!)
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
    }

    private func setCarpoolName(newName: String?) {
        let carpoolNameCell = self.form.formRowWithTag(Tags.CarpoolName.rawValue)
        self.occurrence.carpool.name = newName!

        if newName != nil {
            carpoolNameCell!.value = newName!
        } else {
            carpoolNameCell!.value = self.occurrence.carpool.name
        }
        self.viewDidAppear(false)
        self.tableView.reloadData()
        self.onOccurrenceEdited?(occurrence: self.occurrence)
    }

    // MARK: Methods that make server calls

    func updateCarpoolName(name: String) {
        LoadingView.showWithMaskType(.Black)
        let origName = self.occurrence.carpool.name
        self.occurrence.carpool.name = name
        dataManager.updateCarpool(self.occurrence.carpool) { (success, error, carpoolObj) in
            LoadingView.dismiss()
            if !success && error != "" {
                self.occurrence.carpool.name = origName
                self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
            } else {
                let carpool = carpoolObj as! CarpoolModel
                self.setCarpoolName(carpool.name)
            }
        }
    }

    func updateEventLocation(address: String) {
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
                    self.onOccurrenceEdited?(occurrence: self.occurrence)
                }
            }
        }
    }

    func updateRiderLocation(riderID: Int!, address: String) {
        LoadingView.showWithMaskType(.Black)
        Location.geoCodeAddress(address) { (lon, lat) in
            let location = Location(name: address, long: lon, lati: lat)

            let rider = RiderModel()
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
                    let index = self.occurrence.riders.indexOf(_rider)
                    self.occurrence.riders.removeAtIndex(index!)
                    self.occurrence.riders.insert(_rider, atIndex: index!)
                    self.tableView.reloadData()
                    self.onOccurrenceEdited?(occurrence: self.occurrence)
                }
            }
        }
    }

    func deleteRide(sender: XLFormRowDescriptor) {
        let confirmPrompt = UIAlertController(title: "BE CAREFUL", message: "Are you sure you want to delete this Ride?", preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Type DELETE to confirm"
        }

        confirmPrompt.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))

        confirmPrompt.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alert: UIAlertAction) in
            if let textField = confirmPrompt.textFields?.first as UITextField? {
                if textField.text == "DELETE" {
                    self.dataManager.deleteOccurrence(self.occurrence) { (success, error) in
                        if !success && error != "" {
                            self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
                        } else {
                            self.postNotification("deleteRideOrCarpool")
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        }
                    }
                }
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
        self.deselectFormRow(sender)
    }
    
    func deleteCarpool(sender: XLFormRowDescriptor) {
        let confirmPrompt = UIAlertController(title: "BE CAREFUL", message: "Are you sure you want to delete this Carpool?", preferredStyle: .Alert)
        confirmPrompt.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Type DELETE to confirm"
        }

        confirmPrompt.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))

        confirmPrompt.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alert: UIAlertAction) in
            if let textField = confirmPrompt.textFields?.first as UITextField? {
                if textField.text == "DELETE" {
                    self.dataManager.deleteCarpool(self.occurrence.carpool) { (success, error) in
                        if !success && error != "" {
                            self.showAlert("There was a problem", messege: error, cancleTitle: "OK")
                        } else {
                            self.postNotification("deleteRideOrCarpool")
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        }
                    }
                }
            }
        }))

        presentViewController(confirmPrompt, animated: true, completion: nil)
        self.deselectFormRow(sender)
    }

}
