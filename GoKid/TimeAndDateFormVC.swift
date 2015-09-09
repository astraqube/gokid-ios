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

        var startDateRow = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.StartDate.rawValue)
        var endDateRow = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: Tags.EndDate.rawValue)
        var frequencyRow = XLFormRowDescriptor(tag: Tags.Frequency.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: Tags.Frequency.rawValue)
        var repeatRow = XLFormRowDescriptor(tag: Tags.Repeat.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: Tags.Repeat.rawValue)

        section.addFormRow(startDateRow)
        section.addFormRow(endDateRow)
        section.addFormRow(frequencyRow)
        section.addFormRow(repeatRow)

        startDateRow.cellConfig["textLabel.font"] = labelFont
        startDateRow.cellConfig["textLabel.color"] = labelColor
        startDateRow.cellConfig["detailTextLabel.font"] = valueFont
        startDateRow.cellConfig["detailTextLabel.color"] = labelColor
        startDateRow.cellConfig["minimumDate"] = now
        startDateRow.required = true
        startDateRow.value = carpool.startDate
        startDateRow.valueTransformer = DateTransformer.self

        endDateRow.cellConfig["textLabel.font"] = labelFont
        endDateRow.cellConfig["textLabel.color"] = labelColor
        endDateRow.cellConfig["detailTextLabel.font"] = valueFont
        endDateRow.cellConfig["detailTextLabel.color"] = labelColor
        endDateRow.cellConfig["minimumDate"] = now
        endDateRow.value = carpool.endDate
        endDateRow.valueTransformer = DateTransformer.self
        endDateRow.hidden = "NOT $\(Tags.Repeat.rawValue).value==true"

        frequencyRow.cellConfig["textLabel.font"] = labelFont
        frequencyRow.cellConfig["textLabel.color"] = labelColor
        frequencyRow.cellConfig["detailTextLabel.font"] = valueFont
        frequencyRow.action.viewControllerClass = FrequencyPickerFormVC.self
        frequencyRow.value = GKDays.asKeys.values.array
        frequencyRow.valueTransformer = FrequencyTransformer.self
        frequencyRow.hidden = "NOT $\(Tags.Repeat.rawValue).value==true"

        repeatRow.cellConfig["textLabel.font"] = labelFont
        repeatRow.cellConfig["textLabel.color"] = labelColor
        repeatRow.value = false

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
            endDateCell!.value = isOn ? startDateCell!.value : nil
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

        if let errorMsg = self.isValidFrequentTimeSequence() as String? {
            self.showAlert("Invalid Schedules", messege: errorMsg, cancleTitle: "OK")
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
        let formData = self.form.formValues()
        let startDate = formData[Tags.StartDate.rawValue] as? NSDate
        let endDate = formData[Tags.StartDate.rawValue] as? NSDate

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
        let startTime = formData[Tags.StartTime.rawValue] as? NSDate
        let endTime = formData[Tags.EndTime.rawValue] as? NSDate

        if frequency == nil || frequency!.isEmpty {
            if startTime == nil && endTime == nil {
                return "There's no scheduled time!"
            }

            if startTime != nil && endTime != nil {
                if startTime!.timeString() == endTime!.timeString() || startTime!.isGreaterThanDate(endTime!) {
                    return "These times are out of order!"
                }
            }
        }

        return nil
    }

    func isValidFrequentTimeSequence() -> String? {
        let formData = self.form.formValues()
        let frequency = formData[Tags.Frequency.rawValue] as! [Int]?

        if frequency != nil && !frequency!.isEmpty {
            for f in frequency!.generate() {
                let day = GKDays.dayFromInt(f).truncateToCharacters(3)

                let startTag = "\(Tags.StartTime.rawValue) on \(day)"
                let startTime = formData[startTag] as? NSDate

                let endTag = "\(Tags.EndTime.rawValue) on \(day)"
                let endTime = formData[endTag] as? NSDate

                let onewayTag = "\(Tags.OneWay.rawValue)\(day)"
                let oneway = formData[onewayTag] as? String

                if oneway == "" {
                    if (startTime == nil || endTime == nil) {
                        return "Scheduled times are required!"
                    }

                    if startTime!.timeString() == endTime!.timeString() || startTime!.isGreaterThanDate(endTime!) {
                        return "These times are out of order!"
                    }
                }

                if oneway == CarpoolMode.PickupOnly.rawValue && startTime == nil {
                    return "A scheduled time is required!"
                }

                if oneway == CarpoolMode.DropoffOnly.rawValue && endTime == nil {
                    return "A scheduled time is required!"
                }
            }
        }

        return nil
    }
}
