//
//  TimeAndDateFormVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TimeAndDateFormVC: BaseFormVC {
    
    private enum Tags : String {
        case StartDate = "start_date"
        case EndDate = "end_date"
        case Frequency = "frequency"
        case Repeat = "repeat"
        case StartTime = "start_time"
        case EndTime = "end_time"
        case OneWay = "one_way"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = "Date & Time"
        self.title = userManager.currentCarpoolDescription()
        self.subtitleLabel.text = userManager.currentCarpoolDescription()
        setStatusBarColorDark()
    }
    
    private func updateCarpoolModel() {
        let formData = self.form.formValues()
        let carpoolModel = userManager.currentCarpoolModel
        
        carpoolModel.startDate = formData[Tags.StartDate.rawValue] as? NSDate

        if formData[Tags.Repeat.rawValue] as! Bool {
            carpoolModel.endDate = formData[Tags.EndDate.rawValue] as? NSDate

            let occurence = formData[Tags.Frequency.rawValue] as! NSArray
            carpoolModel.occurence = [] // reset

            for day in occurence {
                if let num = GKDays.asKeys[day as! String] as Int? {
                    carpoolModel.occurence?.append(num)
                }
            }
        } else {
            carpoolModel.endDate = nil
            carpoolModel.occurence = []
        }

        carpoolModel.pickUpTime = formData[Tags.StartTime.rawValue] as? NSDate
        carpoolModel.dropOffTime = formData[Tags.EndTime.rawValue] as? NSDate
    }
    
    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573
        
        let carpoolModel = userManager.currentCarpoolModel

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: "Start Date")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.cellConfig["minimumDate"] = now
        row.required = true
        row.value = carpoolModel.startDate
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: "End Date")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.cellConfig["minimumDate"] = now
        row.hidden = true
        row.value = carpoolModel.endDate
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Frequency.rawValue, rowType: XLFormRowDescriptorTypeSelectorPush, title: "Frequency")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.action.viewControllerClass = FrequencyPickerFormVC.self
        row.hidden = true
        row.value = carpoolModel.occurence == nil ? [] : carpoolModel.occurence
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Repeat.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Repeat")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.value = (carpoolModel.occurence != nil && carpoolModel.occurence?.isEmpty == false)
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: "Start Time")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        row.value = carpoolModel.pickUpTime
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: "End Time")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        row.value = carpoolModel.dropOffTime
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.OneWay.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerView, title: "One-way Carpool")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.selectorOptions = ["", "Pickup Only", "Dropoff Only"]
        row.value = ""
        section.addFormRow(row)
        
        section.footerTitle = "E.g. When the kids are walking to soccer practice after school but need a ride home"
        
        form.addFormSection(section)
        
        self.form = form
        self.form.delegate = self
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        super.formRowDescriptorValueHasChanged(formRow, oldValue: oldValue, newValue: newValue)

        if formRow.tag == Tags.Repeat.rawValue {
            let endDateCell = self.form.formRowWithTag(Tags.EndDate.rawValue)
            let frequencyCell = self.form.formRowWithTag(Tags.Frequency.rawValue)
            
            endDateCell.hidden = !(newValue as! Bool)
            endDateCell.required = newValue as! Bool
            self.updateFormRow(endDateCell)
            
            frequencyCell.hidden = !(newValue as! Bool)
            frequencyCell.required = newValue as! Bool
            self.updateFormRow(frequencyCell)
        }
        
        // enable or disable the next button
        self.rightButton.enabled = self.formValidationErrors().isEmpty
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
        
        var vc = vcWithID("LocationVC")
        self.navigationController?.pushViewController(vc, animated: true)
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

        let startDate = startDateCell.value as? NSDate
        let endDate = endDateCell.value as? NSDate

        let startTimeCell = self.form.formRowWithTag(Tags.StartTime.rawValue)
        let endTimeCell = self.form.formRowWithTag(Tags.EndTime.rawValue)

        let startTime = startTimeCell.value as? NSDate
        let endTime = endTimeCell.value as? NSDate

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
