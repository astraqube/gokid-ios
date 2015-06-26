//
//  TimeAndDateVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class TimeAndDateVC: BaseTVC {
    
    var tableData = [TDCellModel]()
    var dateTimePicker: DateTimePicker!
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
        self.setTableData()
        self.setupDateTimePicker()
        self.clenUserCurrentCarPoolData()
    }
    
    func setUpNavigationBar() {
        var nav = navigationController as! ZGNavVC
        nav.addTitleViewToViewController(self)
        self.title = "Date & Time"
        self.subtitle = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
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
    
    func setTableData() {
        var c1 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c2 = TDCellModel(title: "Start date",      value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c3 = TDCellModel(title: "Repeat",          value: "",       switchValue: false, type: .Switcher, action: .None)
        var c4 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c5 = TDCellModel(title: eventStart,        value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c6 = TDCellModel(title: eventEnd,          value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c7 = TDCellModel(title: "One-way carpool", value: "",       switchValue: false, type: .Switcher, action: .None)
        oneCarpoolModle = c7
        dateModel = c2
        startTimeModel = c5
        endTimeModel = c6
        tableData = [c1, c2, c4, c5, c6]
    }
    
    func setRepetedTableData() {
        var c1 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c2 = TDCellModel(title: "Start Date ",     value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c3 = TDCellModel(title: "End Date ",       value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c4 = TDCellModel(title: "Frequency",       value: ">",      switchValue: true,  type: .Text,     action: .None)
        var c5 = TDCellModel(title: "Repeat",          value: "",       switchValue: true,  type: .Switcher, action: .None)
        var c6 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c7 = TDCellModel(title: eventStart,        value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c8 = TDCellModel(title: eventEnd,          value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c9 = TDCellModel(title: "One-way carpool", value: "",       switchValue: false, type: .Switcher, action: .None)
        oneCarpoolModle = c9
        tableData = [c1, c2, c3, c4, c5, c6, c7, c8, c9]
    }
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        if userManager.currentCarpoolModel.isValid() {
            if userManager.userLoggedIn {
                LoadingView.showWithMaskType(.Black)
                dataManager.createCarpool(userManager.currentCarpoolModel, comp: handleCreateCarpoolSuccess)
            } else {
                moveToLocationVC()
            }
        } else {
            showAlert("Alert", messege: "Please fill in all fields", cancleTitle: "OK")
        }
    }
    
    func handleCreateCarpoolSuccess(success: Bool, errorStr: String) {
        if success {
            dataManager.occurenceOfCarpool(userManager.currentCarpoolModel.id, comp: handleGetVolunteerList)
        } else {
            LoadingView.dismiss()
            self.showAlert("Fail to create carpool", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func handleGetVolunteerList(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            moveToLocationVC()
        } else {
            self.showAlert("Fail to fetch vlounteer list", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func moveToLocationVC() {
        onMainThread() {
            var vc = vcWithID("LocationVC")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func doneButtonClick() {
        var str = dateFormatter.stringFromDate(dateTimePicker.picker.date)
        currentBindLabel?.text = str
        currentBindModel?.valueString = str
        updateCurrentUserCarpoolModel(currentBindModel!, date: dateTimePicker.picker.date)
        dismissDateTimePicker()
    }
    
    func cancleButtonClick() {
        dismissDateTimePicker()
    }
    
    // MARK: TableView DataSource and Delegate
    // --------------------------------------------------------------------------------------------
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = tableData[indexPath.row]
        if model.type == .Empty {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.type == .Text {
            let cell = tableView.cellWithID("TDTextCell", indexPath) as! TDTextCell
            cell.titleLabel.text = model.titleString
            cell.valueLabel.text = model.valueString
            cell.backgroundColor = UIColor.whiteColor()
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
        if _switch_.on == true { setRepetedTableData(); tableView.reloadData() }
        else { setTableData(); tableView.reloadData() }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = tableData[indexPath.row]
        if model.type == .Empty { return 20.0 }
        else if model.type == .Text { return 60.0 }
        else if model.type == .Switcher { return 60.0}
        else { return 50.0 }
    }
    
    func setupDateTimePicker() {
        var h: CGFloat = 280
        dateTimePicker = DateTimePicker(frame: CGRectMake(0, view.h-h, view.w, h))
        dateTimePicker.backgroundColor = UIColor.whiteColor()
        dateTimePicker.addTargetForDoneButton(self, action: "doneButtonClick")
        dateTimePicker.addTargetForCancelButton(self, action: "cancleButtonClick")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var model = tableData[indexPath.row]
        
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
    
    func frequencyCellClicked() {
        var vc = vcWithID("FrequencyPickerVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDateTimePickerWithMode(action: TDCellAction) {
        var mode: UIDatePickerMode = .Date
        if action == .ChooseDate { mode = .DateAndTime; dateFormatter.dateFormat = "EE MMMM d, YYYY" }
        if action == .ChooseTime { mode = .Time; dateFormatter.dateFormat = "hh:mm a" }
        dateTimePicker.setMode(mode)
        
        if dateTimePicker.superview == nil {
            dateTimePicker.alpha = 0.0
            self.view.addSubview(dateTimePicker)
            dateTimePicker.alphaAnimation(1.0, duration: 0.4, completion: nil)
        }
    }
    
    func updateCurrentUserCarpoolModel(cellModel: TDCellModel, date: NSDate ) {
        var cellTitle = cellModel.titleString
        var carpoolModel = userManager.currentCarpoolModel
        if cellTitle == eventStart { // pickup
            carpoolModel.pickUpTime = date
        } else if cellTitle == eventEnd { // drop off
            carpoolModel.dropOffTime = date
        } else if cellTitle == "End date " {
            carpoolModel.endDate = date
        } else if cellTitle == "Start date " {
            carpoolModel.startDate = date
        } else if cellTitle == "Start date" {
            carpoolModel.startDate = date
            carpoolModel.endDate = date
            carpoolModel.occurence = occurenceOfDate(date)
        }
    }
    
    func occurenceOfDate(date: NSDate) -> [Int] {
        var component = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: date)
        var day = component.weekday
        return [day]
    }
  
    func dismissDateTimePicker() {
        dateTimePicker.alphaAnimation(0.0, duration: 0.3) { (anim, finished) in
            self.dateTimePicker.removeFromSuperview()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        dismissDateTimePicker()
    }
}





