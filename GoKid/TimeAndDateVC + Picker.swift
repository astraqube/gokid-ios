//
//  TimeAndDateVC + Picker.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/28/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


extension TimeAndDateVC {
    
    // MARK: Date Time Picker setup
    // --------------------------------------------------------------------------------------------
    
    func setupDateTimePicker() {
        setupTimePicker()
        setupDatePicker()
    }
    
    func setupTimePicker() {
        var h: CGFloat = 280
        timePicker = DateTimePicker(frame: CGRectMake(0, view.h-h, view.w, h))
        timePicker.backgroundColor = UIColor.whiteColor()
        timePicker.addTargetForDoneButton(self, action: "timePickerDoneButtonClick")
        timePicker.addTargetForCancelButton(self, action: "timePickerCancleButtonClick")
    }
    
    func setupDatePicker() {
        datePicker = THDatePickerViewController.datePicker()
        datePicker.delegate = self
        datePicker.setAllowClearDate(false)
        datePicker.setClearAsToday(true)
        datePicker.setAutoCloseOnSelectDate(false)
        datePicker.setAllowSelectionOfSelectedDate(true)
        datePicker.setDisableHistorySelection(true)
        datePicker.setDisableFutureSelection(false)
        datePicker.selectedBackgroundColor = UIColor.darkGrayColor()
        datePicker.currentDateColor = UIColor.blackColor()
        datePicker.currentDateColorSelected = UIColor.whiteColor()
    }
    
    // MARK: Show Date Time Picker
    // --------------------------------------------------------------------------------------------
    
    func showDatePicker() {
        dateFormatter.dateFormat = "EE MMMM d, YYYY"
        datePicker.date = NSDate()
        var options = [
            KNSemiModalOptionKeys.pushParentBack: false,
            KNSemiModalOptionKeys.animationDuration: 0.3,
            KNSemiModalOptionKeys.shadowOpacity: 0.3
        ]
        presentSemiViewController(datePicker, withOptions: options)
    }
    
    func showTimePicker() {
        dateFormatter.dateFormat = "hh:mm a"
        timePicker.setMode(.Time)
        if timePicker.superview == nil {
            timePicker.alpha = 0.0
            self.view.addSubview(timePicker)
            timePicker.alphaAnimation(1.0, duration: 0.4, completion: nil)
        }
    }
    
    // MARK: Date Time Picker Delegate
    // --------------------------------------------------------------------------------------------
    
    func datePickerDonePressed(datePicker: THDatePickerViewController!) {
        var str = dateFormatter.stringFromDate(datePicker.date)
        currentBindLabel?.text = str
        currentBindModel?.valueString = str
        updateCurrentUserCarpoolModel(currentBindModel!, date: datePicker.date)
        self.dismissSemiModalView()
    }
    
    func datePickerCancelPressed(datePicker: THDatePickerViewController!) {
        self.dismissSemiModalView()
    }
    
    func timePickerDoneButtonClick() {
        var str = dateFormatter.stringFromDate(timePicker.picker.date)
        currentBindLabel?.text = str
        currentBindModel?.valueString = str
        updateCurrentUserCarpoolModel(currentBindModel!, date: timePicker.picker.date)
        dismissDateTimePicker()
    }
    
    func timePickerCancleButtonClick() {
        dismissDateTimePicker()
    }
}
