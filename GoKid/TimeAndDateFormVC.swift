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
    var occurrences: [OccurenceModel]?
    var daySchedules: [DaySchedule]!
    var timeSections: [XLFormSectionDescriptor]!

    private enum Tags : String {
        case StartDate = "Start Date"
        case EndDate = "End Date"
        case Frequency = "Frequency"
        case Repeat = "Repeat"
        case StartTime = "Drive to Event"
        case EndTime = "Return from Event"
        case OneWay = "oneWay"
        case OneWayStr = "Carpool Trip"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = "Date & Time"
        self.title = carpool.descriptionString
        self.subtitleLabel.text = carpool.descriptionString
    }
    
    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        form.addFormSection(section)

        row = XLFormRowDescriptor(tag: Tags.Repeat.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.Repeat.rawValue)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.value = false

        row = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.StartDate.rawValue)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minimumDate"] = now
        row.required = true
        row.value = carpool.startDate
        row.valueTransformer = DateTransformer.self

        row = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.EndDate.rawValue)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minimumDate"] = now
        row.value = carpool.endDate
        row.valueTransformer = DateTransformer.self
        row.hidden = "NOT $\(Tags.Repeat.rawValue).value==true"

        row = XLFormRowDescriptor(tag: Tags.Frequency.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.Frequency.rawValue)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.action.viewControllerClass = FrequencyPickerFormVC.self
        row.value = []
        row.valueTransformer = FrequencyTransformer.self
        row.hidden = "NOT $\(Tags.Repeat.rawValue).value==true"

        self.form = form
        self.form.delegate = self

        self.showTimeSectionsForFrequency(nil)
    }

    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        let startDateCell = self.form.formRowWithTag(Tags.StartDate.rawValue)
        let endDateCell = self.form.formRowWithTag(Tags.EndDate.rawValue)
        let frequencyCell = self.form.formRowWithTag(Tags.Frequency.rawValue)

        if formRow.tag == Tags.Repeat.rawValue {
            let isOn = newValue as! Bool
            
            endDateCell!.required = isOn
            endDateCell.value = isOn ? startDateCell.value : nil
            self.updateFormRow(endDateCell)

            if !isOn {
                frequencyCell!.value = []
            }
            self.updateFormRow(frequencyCell)
        }

        if formRow.tag == Tags.Frequency.rawValue {
            self.showTimeSectionsForFrequency(newValue as! [Int]?)
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
            self.showAlert("Invalid Date", messege: errorMsg, cancleTitle: "OK")
            return
        }

        if let errorMsg = self.isValidTimeSequence() as String? {
            self.showAlert("Invalid Time", messege: errorMsg, cancleTitle: "OK")
            return
        }

        self.tableView.endEditing(true)

        self.updateCarpoolModel()
        self.saveCarpoolData()
    }

}

// MARK: Dynamic Time sections
extension TimeAndDateFormVC {

    private func showTimeSectionsForFrequency(frequency: [Int]?) {
        if timeSections != nil && !timeSections.isEmpty {
            for _section in timeSections {
                form.removeFormSection(_section)
            }
        }

        var sections: [XLFormSectionDescriptor]!

        if frequency == nil || frequency!.isEmpty {
            sections = [createTimeSectionForDay(nil)]
        } else {
            sections = frequency?.map { (s: Int) -> XLFormSectionDescriptor in
                return self.createTimeSectionForDay(s)
            }
        }

        timeSections = sections
        tableView.reloadData()
    }

    private func createTimeSectionForDay(occurrenceDay: Int?) -> XLFormSectionDescriptor {
        var startTag: String!
        var endTag: String!
        var onewayTag: String!
        var onewayStr: String!

        if occurrenceDay == nil {
            startTag = Tags.StartTime.rawValue
            endTag = Tags.EndTime.rawValue
            onewayTag = Tags.OneWay.rawValue
            onewayStr = Tags.OneWayStr.rawValue
        } else {
            let day = GKDays.dayFromInt(occurrenceDay!).truncateToCharacters(3)
            startTag = "\(Tags.StartTime.rawValue) on \(day)"
            endTag = "\(Tags.EndTime.rawValue) on \(day)"
            onewayTag = "\(Tags.OneWay.rawValue)\(day)"
            onewayStr = "\(Tags.OneWayStr.rawValue) on \(day)"
        }

        var row: XLFormRowDescriptor!
        var section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        form.addFormSection(section)

        row = XLFormRowDescriptor(tag: onewayTag, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: onewayStr)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.selectorOptions = CarpoolMode.allValues
        row.value = ""
        row.valueTransformer = OneWayTransformer.self
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: startTag, rowType: XLFormRowDescriptorTypeTime, title: startTag)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minuteInterval"] = 5
        row.hidden = "$\(onewayTag).value=='\(CarpoolMode.DropoffOnly.rawValue)'"

        row = XLFormRowDescriptor(tag: endTag, rowType: XLFormRowDescriptorTypeTime, title: endTag)
        section.addFormRow(row)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        row.cellConfig["minuteInterval"] = 5
        row.hidden = "$\(onewayTag).value=='\(CarpoolMode.PickupOnly.rawValue)'"

        if occurrenceDay == nil {
            section.footerTitle = "E.g. When kids are walking to soccer practice from school and only need a ride home."
        }

        return section
    }

}

// MARK: Form Submission
extension TimeAndDateFormVC {

    private func updateCarpoolModel() {
        let formData = self.form.formValues()
        let frequency = formData[Tags.Frequency.rawValue] as! [Int]?
        let startDate = formData[Tags.StartDate.rawValue] as? NSDate
        let endDate = formData[Tags.EndDate.rawValue] as? NSDate
        let isRepeating = formData[Tags.Repeat.rawValue] as! Bool

        if frequency != nil && !frequency!.isEmpty {
            carpool.schedules = frequency?.map { (key: Int) -> DaySchedule in
                let day = GKDays.dayFromInt(key).truncateToCharacters(3)
                let startTag = "\(Tags.StartTime.rawValue) on \(day)"
                let endTag = "\(Tags.EndTime.rawValue) on \(day)"
                let onewayTag = "\(Tags.OneWay.rawValue)\(day)"

                var ds = DaySchedule()
                ds.dayNum = key
                ds.startDate = startDate
                ds.endDate = endDate
                ds.pickUpTime = formData[startTag] as! NSDate?
                ds.dropOffTime = formData[endTag] as! NSDate?
                ds.oneWay = CarpoolMode(rawValue: formData[onewayTag] as! String)
                
                return ds
            }

        } else {
            carpool.startDate = startDate
            carpool.endDate = isRepeating ? endDate : startDate
            carpool.pickUpTime = formData[Tags.StartTime.rawValue] as? NSDate
            carpool.dropOffTime = formData[Tags.EndTime.rawValue] as? NSDate
            carpool.oneWay = CarpoolMode(rawValue: formData[Tags.OneWay.rawValue] as! String)
        }
    }

    private func saveCarpoolData() {
        if carpool.id > 0 {
            updateCarpoolData()
        } else {
            createCarpoolData()
        }
    }

    private func createCarpoolData() {
        LoadingView.showWithMaskType(.Black)
        dataManager.createCarpool(carpool) { (success, errorMessage, carpoolObj) -> () in
            LoadingView.dismiss()
            self.proceedToNextStep(success, errorMessage: errorMessage, carpoolObj: carpoolObj)
        }
    }

    private func updateCarpoolData() {
        LoadingView.showWithMaskType(.Black)
        dataManager.updateCarpool(carpool) { (success, errorMessage, carpoolObj) -> () in
            LoadingView.dismiss()
            self.proceedToNextStep(success, errorMessage: errorMessage, carpoolObj: carpoolObj)
        }
    }

    private func proceedToNextStep(success: Bool, errorMessage: String, carpoolObj: AnyObject?) {
        if success {
            var vc = vcWithID("LocationVC") as! LocationVC
            vc.carpool = carpoolObj as! CarpoolModel
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if errorMessage != "Access Denied" {
                self.showAlert("Failed to create carpool", messege: errorMessage, cancleTitle: "OK")
            }
        }
    }

}

// MARK: Table header icons
extension TimeAndDateFormVC {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var imageIcon = UIImage(named: section == 0 ? "date" : "time")
        var imageView = UIImageView(image: imageIcon)
        var header = UIView(frame: CGRectMake(0,0, tableView.bounds.size.width, 40))
        
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

        if startDate != nil && endDate != nil {
            if startDate!.isGreaterThanDate(endDate!) {
                return "These dates are out of order!"
            }
        }

        return nil
    }

    func isValidTimeSequence() -> String? {
        let formData = self.form.formValues()
        let frequency = formData[Tags.Frequency.rawValue] as! [Int]?

        if frequency != nil && frequency!.isEmpty {
            let startTimeCell = self.form.formRowWithTag(Tags.StartTime.rawValue)
            let endTimeCell = self.form.formRowWithTag(Tags.EndTime.rawValue)

            let startTime = startTimeCell!.value as? NSDate
            let endTime = endTimeCell!.value as? NSDate

            if startTime == nil && endTime == nil {
                return "There's no scheduled time!"
            }

            if startTime != nil && endTime != nil {
                if startTime!.isGreaterThanDate(endTime!) {
                    return "These times are out of order!"
                }
            }
        }
        
        return nil
    }
    
}
