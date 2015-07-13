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
        self.subtitleLabel.text = userManager.currentCarpoolDescription()
        setStatusBarColorDark()
    }
    
    func resetCarpoolModel() {
        var model = userManager.currentCarpoolModel
        model.startDate = nil
        model.endDate = nil
        model.pickUpTime = nil
        model.dropOffTime = nil
    }
    
    private func updateCarpoolModel() {
        let formData = self.form.formValues()
        let carpoolModel = userManager.currentCarpoolModel
        
        carpoolModel.startDate = formData[Tags.StartDate.rawValue] as? NSDate
        carpoolModel.endDate = formData[Tags.EndDate.rawValue] as? NSDate

        carpoolModel.pickUpTime = formData[Tags.StartTime.rawValue] as? NSDate
        carpoolModel.dropOffTime = formData[Tags.EndTime.rawValue] as? NSDate
        
        // FIXME: unclear on what this is really doing
        carpoolModel.occurence = self.occurenceOfDate(carpoolModel.startDate!)
    }
    
    private func occurenceOfDate(date: NSDate) -> [Int] {
        var component = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        var day = component.weekday - 1
        return [day]
    }
    
    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let fontValue = UIFont(name: "Raleway-Bold", size: 17)!
        let colorLabel = colorManager.color507573
        
        self.resetCarpoolModel()
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: "Start Date")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.cellConfig["minimumDate"] = now
        row.required = true
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndDate.rawValue, rowType: XLFormRowDescriptorTypeDate, title: "End Date")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.cellConfig["minimumDate"] = now
        row.hidden = "$\(Tags.Repeat.rawValue)==0"
        row.valueTransformer = DateTransformer.self
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Frequency.rawValue, rowType: XLFormRowDescriptorTypeMultipleSelector, title: "Frequency")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.selectorOptions = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        row.hidden = "$\(Tags.Repeat.rawValue)==0"
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.Repeat.rawValue, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Repeat")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.value = 0
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: Tags.StartTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: "Start Time")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.EndTime.rawValue, rowType: XLFormRowDescriptorTypeTime, title: "End Time")
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.cellConfig["detailTextLabel.font"] = fontValue
        row.cellConfig["detailTextLabel.color"] = colorLabel
        row.required = true
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: Tags.OneWay.rawValue, rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: "One-way Carpool")
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
            
            endDateCell.required = newValue as! Bool
            self.updateFormRow(endDateCell)
            
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
