//
//  TimeAndDateFormVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TimeAndDateFormVC: BaseFormVC {

    var carpool: CarpoolModel!

    private enum Tags : String {
        case StartDate = "Start Date"
        case EndDate = "End Date"
        case Frequency = "Frequency"
        case Repeat = "Repeat"
        case StartTime = "Arrive at Event"
        case EndTime = "Depart from Event"
        case OneWay = "One-way Carpool"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = "Date & Time"
        self.title = carpool.descriptionString
        self.subtitleLabel.text = carpool.descriptionString
    }
    
    private func updateCarpoolModel() {
        let formData = self.form.formValues()

        carpool.startDate = formData[Tags.StartDate.rawValue] as? NSDate

        if formData[Tags.Repeat.rawValue] as! Bool {
            carpool.endDate = formData[Tags.EndDate.rawValue] as? NSDate
            carpool.occurence = formData[Tags.Frequency.rawValue] as? [Int]
        } else {
            carpool.endDate = nil
            carpool.occurence = nil
        }

        carpool.pickUpTime = formData[Tags.StartTime.rawValue] as? NSDate
        carpool.dropOffTime = formData[Tags.EndTime.rawValue] as? NSDate
    }

    private func createCarpoolData() {
        LoadingView.showWithMaskType(.Black)
        dataManager.createCarpool(carpool) { (success, errorMessage) -> () in
            LoadingView.dismiss()
            if success {
                var vc = vcWithID("LocationVC") as! LocationVC
                vc.carpool = self.carpool
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showAlert("Fail to create carpool", messege: errorMessage, cancleTitle: "OK")
            }
        }
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.StartDate.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minimumDate"] = now
        row.required = true
        row.value = carpool.startDate
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.EndDate.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minimumDate"] = now
        row.hidden = true
        row.value = carpool.endDate
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Frequency.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.Frequency.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.action.viewControllerClass = FrequencyPickerFormVC.self
        row.valueTransformer = FrequencyTransformer.self
        row.hidden = true
        row.value = carpool.occurence
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Repeat.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.Repeat.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.value = (carpool.occurence != nil && carpool.occurence?.isEmpty == false)
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: Tags.StartTime.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.required = true
        row.value = carpool.pickUpTime
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: Tags.EndTime.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.required = true
        row.value = carpool.dropOffTime
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.OneWay.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: Tags.OneWay.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.selectorOptions = ["", "Pickup Only", "Dropoff Only"]
        row.value = ""
        section.addFormRow(row)
        
        section.footerTitle = "E.g. When kids are walking to soccer practice from school and only need a ride home."
        
        form.addFormSection(section)
        
        self.form = form
        self.form.delegate = self
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.Repeat.rawValue {
            let endDateCell = self.form.formRowWithTag(Tags.EndDate.rawValue)
            let frequencyCell = self.form.formRowWithTag(Tags.Frequency.rawValue)
            
            endDateCell!.hidden = !(newValue as! Bool)
            endDateCell!.required = newValue as! Bool
            self.updateFormRow(endDateCell)
            
            frequencyCell!.hidden = !(newValue as! Bool)
            self.updateFormRow(frequencyCell)
        }

        self.toggleRightNavButtonState()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        var formRow = self.form.formRowAtIndex(indexPath)

        if contains([XLFormRowDescriptorTypeDate, XLFormRowDescriptorTypeTime], formRow!.rowType) {
            if formRow!.value == nil {
                formRow!.value = NSDate()
                self.updateFormRow(formRow)
            }
        }
    }

    override func rightNavButtonTapped() {
        let validationErrors: Array<NSError> = self.formValidationErrors() as! Array<NSError>

        if validationErrors.count > 0 {
            self.showFormValidationError(validationErrors.first)
            return
        }

        if let errorMsg = self.isValidDateSequence() as String? {
            self.showAlert("Invalid Schedule", messege: errorMsg, cancleTitle: "OK")
            return
        }

        self.tableView.endEditing(true)

        self.updateCarpoolModel()
        self.createCarpoolData()
    }

}


// MARK: Table header icons
extension TimeAndDateFormVC {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var imageIcon = UIImage(named: section == 0 ? "date" : "time")
        var imageView = UIImageView(image: imageIcon)
        var header = UIView(frame: CGRectMake(0,0, tableView.bounds.size.width, 50))
        
        imageView.center = CGPointMake(header.bounds.size.width/2, header.bounds.size.height/2)
        
        header.backgroundColor = UIColor.whiteColor()
        header.addSubview(imageView)
        
        return header
    }
    
}

// MARK: Validators
extension TimeAndDateFormVC {

    func isValidDateSequence() -> String? {
        let startDateCell = self.form.formRowWithTag(Tags.StartDate.rawValue)
        let endDateCell = self.form.formRowWithTag(Tags.EndDate.rawValue)

        let startDate = startDateCell!.value as? NSDate
        let endDate = endDateCell!.value as? NSDate

        let startTimeCell = self.form.formRowWithTag(Tags.StartTime.rawValue)
        let endTimeCell = self.form.formRowWithTag(Tags.EndTime.rawValue)

        let startTime = startTimeCell!.value as? NSDate
        let endTime = endTimeCell!.value as? NSDate

        if startDate != nil && endDate != nil {
            if startDate!.isGreaterThanDate(endDate!) {
                return "These dates are out of order!"
            }
        }

        if startDate != nil && endDate == nil {
            if startTime!.isGreaterThanDate(endTime!) {
                return "These times are out of order!"
            }
        }

        return nil
    }

}
