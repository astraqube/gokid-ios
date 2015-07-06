//
//  VolunteerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/28/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension VolunteerVC {
    
    // MARK: Handle Action Sheet
    // --------------------------------------------------------------------------------------------
    
    func showActionSheet(cell: VolunteerCell) {
        var row = self.tableView.indexPathForCell(cell)!.row
        var model = self.dataSource[row]
        if model.taken {
            showTakenActionSheet(cell, model: model)
        } else{
            showUntakenActionSheet(cell, model: model)
        }
    }
    
    func showTakenActionSheet(cell: VolunteerCell, model: CalendarModel) {
        let button1 = UIAlertAction(title: "Unvolunteer", style: .Default) { (alert) in
            self.unRegisterVolunteerForCell(cell, model: model)
        }
        let button2 = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in
            
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(button1)
        alert.addAction(button2)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showUntakenActionSheet(cell: VolunteerCell, model: CalendarModel) {
        let button1 = UIAlertAction(title: "Volunteer", style: .Default) { (alert) in
            self.registerVolunteerForCell(cell, model: model)
        }
        let button3 = UIAlertAction(title: "Volunteer All Drop-off", style: .Default) { (alert) in
            self.registerVolunteerForCell(cell, model: model)
        }
        let button4 = UIAlertAction(title: "Volunteer Every Day", style: .Default) { (alert) in
            self.registerVolunteerForCell(cell, model: model)
        }
        let button5 = UIAlertAction(title: "Assign team member", style: .Default) { (alert) in
        }
        let button6 = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) in
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(button1)
        alert.addAction(button3)
        alert.addAction(button4)
        alert.addAction(button5)
        alert.addAction(button6)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func unRegisterVolunteerForCell(cell: VolunteerCell, model: CalendarModel) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.unregisterForOccurence(model.carpoolID, occurID: model.occrencID) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    cell.checkButton.backgroundColor = UIColor.lightGrayColor()
                    model.taken = !model.taken
                } else {
                    self.showAlert("Fail to unvolunteer", messege: errStr, cancleTitle: "OK")
                }
            }
        }
    }
    
    func registerVolunteerForCell(cell: VolunteerCell, model: CalendarModel) {
        LoadingView.showWithMaskType(.Black)
        self.dataManager.registerForOccurence(model.carpoolID, occurID: model.occrencID) { (success, errStr) in
            LoadingView.dismiss()
            onMainThread() {
                if success {
                    cell.checkButton.backgroundColor = UIColor.greenColor()
                    model.taken = !model.taken
                } else {
                    self.showAlert("Fail to volunteer", messege: errStr, cancleTitle: "OK")
                }}
        }
    }
}
