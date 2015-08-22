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
    case Daily = "Daily"
    case EveryWeek = "Every Week"
//    case EveryMonth = "Every Month"
//    case EveryYear = "Every Year"

    static let allValues = [
        JustOnce.rawValue, Daily.rawValue, EveryWeek.rawValue,
//        EveryMonth.rawValue, EveryYear.rawValue
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

    static func dayFromInt(num: Int) -> String {
        let list = self.asKeys
        if contains(list.values, num) {
            return list.keys[find(list.values, num)!]
        } else {
            return ""
        }
    }
}


class FrequencyPickerFormVC: BaseFormVC, XLFormRowDescriptorViewController {

    var rowDescriptor: XLFormRowDescriptor!

    private var currentValues: NSMutableArray! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .None
        self.title = "Frequency"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

        if let current = self.rowDescriptor.value as? [AnyObject] {
            self.currentValues.addObjectsFromArray(self.convertValuesToForm(current))
        }
        self.updateFormFields()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.rowDescriptor.value = self.convertFormToValues(self.currentValues as [AnyObject])
    }

    override func initForm() {
        let form = XLFormDescriptor()
        var row: XLFormRowDescriptor!
        var section: XLFormSectionDescriptor!

        section = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor

        row = XLFormRowDescriptor(tag: GKFrequency.JustOnce.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.JustOnce.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.value = self.isChecked(GKFrequency.JustOnce.rawValue)
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: GKFrequency.Daily.rawValue,
            rowType: XLFormRowDescriptorTypeBooleanCheck,
            title: GKFrequency.Daily.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        row.value = self.isChecked(GKFrequency.Daily.rawValue)
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: GKFrequency.EveryWeek.rawValue,
                                  rowType: XLFormRowDescriptorTypeBooleanCheck,
                                  title: GKFrequency.EveryWeek.rawValue)
        row.cellConfig["textLabel.font"] = labelFont
        row.cellConfig["textLabel.color"] = labelColor
        section.addFormRow(row)

        for day in GKDays.allValues {
            row = XLFormRowDescriptor(tag: day,
                rowType: XLFormRowDescriptorTypeBooleanCheck,
                title: "      "+day)
            row.cellConfig["textLabel.font"] = labelFont
            row.cellConfig["textLabel.color"] = labelColor
            row.value = self.isChecked(day)
            row.hidden = true
            section.addFormRow(row)
        }
/* NOT YET SUPPORTED
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
*/
        form.addFormSection(section)

        self.form = form
        self.form.delegate = self
    }

   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)

        var formRow = self.form.formRowAtIndex(indexPath)

        // Top-level acts as radio buttons
        if contains(GKFrequency.allValues, formRow!.tag!) {
            self.currentValues.removeAllObjects()
        }

        if formRow!.tag != GKFrequency.JustOnce.rawValue {
            if formRow!.value as! Bool {
                self.currentValues.addObject(formRow!.tag!)
            } else {
                self.currentValues.removeObject(formRow!.tag!)
            }
        }

        if formRow!.tag == GKFrequency.Daily.rawValue {
            self.currentValues.addObjectsFromArray(GKDays.asKeys.keys.array)
        }

        self.updateFormFields()
    }

    func updateRowDescriptor() {
        if self.currentValues.count > 0 {
            var collection: [Int] = []
            for val in self.currentValues {
                let valStr = val as! String
                if contains(GKDays.asKeys.keys, valStr) {
                    if let num = GKDays.asKeys[valStr] as Int? {
                        collection.append(num)
                    }
                }
            }

            self.rowDescriptor.value = collection
        } else {
            self.rowDescriptor.value = nil
        }
    }

    func updateFormFields() {
        for tag in (GKFrequency.allValues) {
            let fieldCell = self.form.formRowWithTag(tag)
            fieldCell!.value = self.isChecked(tag)
            self.updateFormRow(fieldCell)
        }

        for tag in (GKDays.allValues) {
            let fieldCell = self.form.formRowWithTag(tag)
            fieldCell!.value = self.isChecked(tag)
            fieldCell!.hidden = !self.isChecked(GKFrequency.EveryWeek.rawValue)
            self.updateFormRow(fieldCell)
        }
    }

    func isChecked(val: String!) -> Bool {
        if val == GKFrequency.JustOnce.rawValue {
            return self.currentValues.count == 0
        }

        if self.currentValues.count > 0 && contains(GKDays.asKeys.keys, self.currentValues.firstObject as! String) {
            if val == GKFrequency.Daily.rawValue && self.currentValues.count == 7 {
                return true
            }

            if val == GKFrequency.EveryWeek.rawValue && self.currentValues.count < 7 {
                return true
            }
        }

        return self.currentValues.containsObject(val)
    }

    func convertValuesToForm(data: [AnyObject]) -> [String] {
        var converted: [String]! = []

        for _val in data {
            let val = _val as! Int
            if contains(GKDays.asKeys.values, val) {
                let day: String = GKDays.asKeys.keys[find(GKDays.asKeys.values, val)!]
                converted.append(day)
            }
        }

        return converted
    }

    func convertFormToValues(data: [AnyObject]) -> [Int] {
        var converted: [Int]! = []

        for _field in data {
            let field = _field as! String
            if contains(GKDays.asKeys.keys, field) {
                let dayNum: Int = GKDays.asKeys[field]!
                converted.append(dayNum)
            }
        }

        converted.sort {
            return $0 < $1
        }

        return converted
    }

}
