//
//  TimeAndDateVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TimeAndDateVC: BaseTVC, THDatePickerDelegate {
    
    var dataSource = [TDCellModel]()
    var timePicker: DateTimePicker!
    var datePicker: THDatePickerViewController!
    var dateFormatter = NSDateFormatter()
    
    var currentBindLabel: UILabel?
    var oneCarpoolModle: TDCellModel!
    var goOnly = false
    var returnOnly = false
    
    var currentBindModel: TDCellModel?
    var dateModel: TDCellModel?
    var startTimeModel: TDCellModel?
    var endTimeModel: TDCellModel?
    
    let eventStart = "Start Time"
    let eventEnd = "End Time"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        self.dataManager.fakeTimeAndDateTableViewData(self)
        self.setupDateTimePicker()
        self.clenUserCurrentCarPoolData()
    }
    
    func setUpNavigationBar() {
        var nav = navigationController as! ZGNavVC
        nav.addTitleViewToViewController(self)
        self.title = "Date & Time"
        self.subtitle = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
        setStatusBarColorDark()
        setNavBarColor(colorManager.appLightGreen)
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    func clenUserCurrentCarPoolData() {
        var model = userManager.currentCarpoolModel
        model.startDate = nil
        model.endDate = nil
        model.pickUpTime = nil
        model.dropOffTime = nil
    }
  
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        if userManager.currentCarpoolModel.isValidForTime() {
            var vc = vcWithID("LocationVC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showAlert("Alert", messege: "Please fill in all fields", cancleTitle: "OK")
        }
    }
    
    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = dataSource[indexPath.row]
        if model.type == .Empty {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.type == .Text {
            let cell = tableView.cellWithID("TDTextCell", indexPath) as! TDTextCell
            cell.titleLabel.text = model.titleString
            cell.valueLabel.text = model.valueString
            if model.titleString == eventStart {
                if returnOnly == true {
                    cell.backgroundColor = ColorManager.sharedInstance.lightGrayColor
                    cell.valueLabel.text = ""
                }
            }
            if model.titleString == eventEnd {
                if goOnly == true {
                    cell.backgroundColor = ColorManager.sharedInstance.lightGrayColor
                    cell.valueLabel.text = ""
                }
            }
            return cell
        } else if model.type == .Switcher {
            let cell = tableView.cellWithID("TDSwitchCell", indexPath) as! TDSwitchCell
            cell.titleLabel.text = model.titleString
            cell.switcher.setOn(model.switchValue, animated: true)
            if model.titleString == "Repeat" {
                cell.switcherAction = repeteSwitcherSwitched
            }
            if model.titleString == "One-way carpool" {
                cell.switcherAction = oneWayCarpoolSwitched
            }
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
    }
    
    // MARK: TableView Delegate
    // --------------------------------------------------------------------------------------------
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = dataSource[indexPath.row]
        if model.type == .Empty { return 20.0 }
        else if model.type == .Text { return 60.0 }
        else if model.type == .Switcher { return 60.0}
        else { return 50.0 }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var model = dataSource[indexPath.row]
        if model.titleString == "Frequency" {
            frequencyCellClicked()
            return
        }
        if model.action == .ChooseDate || model.action == .ChooseTime {
            var cell = tableView.cellForRowAtIndexPath(indexPath) as! TDTextCell
            showDateTimePickerWithMode(model.action)
            currentBindModel = model
            currentBindLabel = cell.valueLabel
        }
    }
    
    func oneWayCarpoolSwitched(_switch_: UISwitch) {
        oneCarpoolModle.switchValue = !oneCarpoolModle.switchValue
        // if the switch is on, let it turn off and do noting
        if _switch_.on == false {
            returnOnly = false
            goOnly = false
            tableView.reloadData()
            return
        }
        
        let goButton = UIAlertAction(title: "Go to event only", style: .Default) { (alert) in
            self.goOnly = true
            self.returnOnly = false
            self.tableView.reloadData()
        }
        let returnButton = UIAlertAction(title: "Return from event only", style: .Default) { (alert) in
            self.goOnly = false
            self.returnOnly = true
            self.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Cancle", style: .Cancel) { (alert) in
            _switch_.setOn(false, animated: true)
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(goButton)
        alert.addAction(returnButton)
        alert.addAction(cancelButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func repeteSwitcherSwitched(_switch_: UISwitch) {
        if _switch_.on == true {
            dataManager.fakeTimeAndDateRepetedTableViewData(self)
            tableView.reloadData()
        }
        else {
            dataManager.fakeTimeAndDateTableViewData(self)
            tableView.reloadData()
        }
    }
    
    func frequencyCellClicked() {
        var vc = vcWithID("FrequencyPickerVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDateTimePickerWithMode(action: TDCellAction) {
        if action == .ChooseDate { showDatePicker() }
        if action == .ChooseTime { showTimePicker() }
    }
    
    func updateCurrentUserCarpoolModel(cellModel: TDCellModel, date: NSDate ) {
        var cellTitle = cellModel.titleString
        var carpoolModel = userManager.currentCarpoolModel
        if cellTitle == eventEnd { // pickup
            carpoolModel.pickUpTime = date
        } else if cellTitle == eventStart { // drop off
            carpoolModel.dropOffTime = date
        } else if cellTitle == "End date " {
            carpoolModel.endDate = date
        } else if cellTitle == "Start date " {
            carpoolModel.startDate = date
        } else if cellTitle == "Start date" {
            carpoolModel.startDate = date
            carpoolModel.endDate = date
            carpoolModel.occurence = occurenceOfDate(date)
            println(carpoolModel.occurence)
            println(date)
        }
    }
    
    func occurenceOfDate(date: NSDate) -> [Int] {
        var component = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        var day = component.weekday - 1
        return [day]
    }
  
    func dismissDateTimePicker() {
        timePicker.alphaAnimation(0.0, duration: 0.3) { (anim, finished) in
            self.timePicker.removeFromSuperview()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        dismissDateTimePicker()
    }
}





