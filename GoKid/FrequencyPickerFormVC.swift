//
//  FrequencyPickerFormVC.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/13/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

enum GKFrequency : String {
    case JustOnce = "Just Once"
    case EveryWeek = "Every Week"
    case EveryMonth = "Every Month"
    case EveryYear = "Every Year"

    static let allValues = [
        JustOnce.rawValue, EveryWeek.rawValue,
        EveryMonth.rawValue, EveryYear.rawValue
    ]
}

enum GKDays : String {
    case Sunday = "Sunday"
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"

    static let allValues = [
        Sunday.rawValue, Monday.rawValue, Tuesday.rawValue, Wednesday.rawValue,
        Thursday.rawValue, Friday.rawValue, Saturday.rawValue
    ]

    // FIXME: this may be temporary
    static let asKeys = [
        Sunday.rawValue:0, Monday.rawValue:1, Tuesday.rawValue:2, Wednesday.rawValue:3,
        Thursday.rawValue:4, Friday.rawValue:5, Saturday.rawValue:6
    ]
}


class FrequencyPickerFormVC: BaseFormVC, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor?

    private var currentValues: NSMutableArray! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.currentValues.addObjectsFromArray(self.rowDescriptor?.value as! Array)
        self.updateFormFields()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        let now = NSDate()
        let fontLabel = UIFont(name: "Raleway-Light", size: 17)!
        let colorLabel = colorManager.color507573

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: GKFrequency.JustOnce.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.JustOnce.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.value = self.isChecked(GKFrequency.JustOnce.rawValue)
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: GKFrequency.EveryWeek.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.EveryWeek.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        section.addFormRow(row)

        for day in GKDays.allValues {
            row = XLFormRowDescriptor(tag: day,
                rowType: XLFormRowDescriptorTypeBooleanCheck,
                title: "      "+day)
            row.cellConfig["textLabel.font"] = fontLabel
            row.cellConfig["textLabel.color"] = colorLabel
            row.value = self.isChecked(day)
            row.hidden = true
            section.addFormRow(row)
        }

        row = XLFormRowDescriptor(tag: GKFrequency.EveryMonth.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.EveryMonth.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.value = self.isChecked(GKFrequency.EveryMonth.rawValue)
        row.disabled = true // TODO: disabled until requirements are clear
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: GKFrequency.EveryYear.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.EveryYear.rawValue)
        row.cellConfig["textLabel.font"] = fontLabel
        row.cellConfig["textLabel.color"] = colorLabel
        row.value = self.isChecked(GKFrequency.EveryYear.rawValue)
        row.disabled = true // TODO: disabled until requirements are clear
        section.addFormRow(row)

        form.addFormSection(section)

        self.form = form
        self.form.delegate = self
    }

   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        var formRow = self.form.formRowAtIndex(indexPath)

        // Top-level acts as radio buttons
        if contains(GKFrequency.allValues, formRow.tag) {
            self.currentValues.removeAllObjects()
        }

        if formRow.tag == GKFrequency.EveryWeek.rawValue {
            if formRow.value as! Bool {
                self.currentValues.addObjectsFromArray(GKDays.allValues)
            }
        }

        if formRow.tag != GKFrequency.JustOnce.rawValue {
            if formRow.value as! Bool {
                self.currentValues.addObject(formRow.tag)
            } else {
                self.currentValues.removeObject(formRow.tag)
            }
        }

        self.rowDescriptor?.value = self.currentValues as Array
        self.updateFormFields()
    }

    func updateFormFields() {
        for tag in (GKFrequency.allValues) {
            let fieldCell = self.form.formRowWithTag(tag)
            fieldCell.value = self.isChecked(tag)
            self.updateFormRow(fieldCell)
        }

        for tag in (GKDays.allValues) {
            let fieldCell = self.form.formRowWithTag(tag)
            fieldCell.value = self.isChecked(tag)
            fieldCell.hidden = !self.isChecked(GKFrequency.EveryWeek.rawValue)
            self.updateFormRow(fieldCell)
        }
    }

    func isChecked(val: String!) -> Bool {
        if val == GKFrequency.JustOnce.rawValue {
            return self.currentValues.count == 0
        }

        if val == GKFrequency.EveryWeek.rawValue && self.currentValues.count > 0 {
            if contains(GKDays.allValues, self.currentValues.firstObject as! String) {
                return true
            }
        }

        return self.currentValues.containsObject(val)
    }

}