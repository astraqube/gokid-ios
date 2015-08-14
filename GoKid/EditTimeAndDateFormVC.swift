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
        self.subtitleLabel.text = carpoolModel.descriptionString//userManager.currentCarpoolDescription()
        
        occurrences = self.processRawCalendarEvents(occurrences)
    }
    
    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!
        
        let now = NSDate()
        
        //let carpoolModel = userManager.currentCarpoolModel
        
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
                
                row = XLFormRowDescriptor(tag: "asdf", rowType: XLFormRowDescriptorTypeInfo, title: occurrence.occursAtStr)
                row.cellConfig["textLabel.font"] = labelFont
                row.cellConfig["textLabel.color"] = labelColor
                row.cellConfig["detailTextLabel.font"] = valueFont
                row.cellConfig["detailTextLabel.color"] = labelColor
                section.addFormRow(row)
                
                lastDateStr = occurrence.occursAtStr
            }

            row = XLFormRowDescriptor(tag: "occurrence", rowType: XLFormRowDescriptorTypeTime, title: occurrence.poolType)
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
    
    func processRawCalendarEvents(events: [OccurenceModel]) -> [OccurenceModel] {
        var data = [OccurenceModel]()
        var lastDateStr = ""
        for event in events {
            if event.occursAtStr != lastDateStr {
                var dateCell = OccurenceModel()
                dateCell.cellType = .Time
                dateCell.occursAtStr = event.occursAtStr
                data.append(dateCell)
                lastDateStr = event.occursAtStr
            }
            data.append(event)
        }
        return data
    }

}
