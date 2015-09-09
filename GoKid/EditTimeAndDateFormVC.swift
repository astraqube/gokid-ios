//
//  EditTimeAndDateFormVC.swift
//  GoKid
//
//  Created by Hoan Ton-That on 8/13/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


class EditTimeAndDateFormVC : BaseFormVC {
    var carpoolModel: CarpoolModel = CarpoolModel()
    var occurrences = [OccurenceModel()]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = "Edit Date & Time"
        self.subtitleLabel.text = carpoolModel.descriptionString
        
        //  occurrences = self.processRawCalendarEvents(occurrences)
    }
    
    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        
        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: "asdf", rowType: XLFormRowDescriptorTypeInfo, title: occurrences[0].occursAtStr)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.cellConfig["detailTextLabel.font"] = valueFont
        row.cellConfig["detailTextLabel.color"] = labelColor
        section.addFormRow(row)

        var lastDateStr = occurrences[0].occursAtStr

        for occurrence in occurrences {
            if occurrence.occursAtStr != lastDateStr {
                form.addFormSection(section)

                section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
                
                row = XLFormRowDescriptor(tag: "heading", rowType: XLFormRowDescriptorTypeInfo, title: occurrence.occursAtStr)
                row.cellConfig["textLabel.font"] = labelFont
                row.cellConfig["textLabel.color"] = labelColor
                row.cellConfig["detailTextLabel.font"] = valueFont
                row.cellConfig["detailTextLabel.color"] = labelColor
                section.addFormRow(row)
                
                lastDateStr = occurrence.occursAtStr
            }

            row = XLFormRowDescriptor(tag: String(occurrence.occurenceID), rowType: XLFormRowDescriptorTypeTime, title: occurrence.poolType)
            row.cellConfig["textLabel.font"] = labelFont
            row.cellConfig["textLabel.color"] = labelColor
            row.cellConfig["detailTextLabel.font"] = valueFont
            row.cellConfig["detailTextLabel.color"] = labelColor
            row.cellConfig["minimumDate"] = now
            row.required = true
            row.value = occurrence.occursAt
            row.valueTransformer = TimeTransformer.self
            section.addFormRow(row)

        }
        
        form.addFormSection(section)

        self.form = form
        self.form.delegate = self
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
        let formData = self.form.formValues()
        
        let updates = NSMutableDictionary.new()
        
        for o in occurrences {
            let _id = String(o.occurenceID)
            let date = formData[_id] as! NSDate
            
            updates[_id] = ["occurs_at": date.iso8601String()]
        }
        
        NSLog("updates %@", updates)
        
        dataManager.updateOccurencesTimes2(updates, comp: { (success, error) -> () in
            if success {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.showAlert("Error", messege: "Couldn't save times", cancleTitle: "Ok")
            }
        })
        
    }

}
