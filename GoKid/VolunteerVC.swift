//
//  VolunteerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableData = [VolunteerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupTableData()
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTableData() {
        var str = "Volunteer as Driver"
        var c0 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c1 = VolunteerModel(title: "", time: "April 24, Fri", poolType: "", cellType: .Date)
        var c2 = VolunteerModel(title: str, time: "12.00 pm", poolType: "Drop-off", cellType: .Normal)
        var c3 = VolunteerModel(title: str, time: "1.00 pm", poolType: "Pick-up", cellType: .Normal)
        
        var c4 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c5 = VolunteerModel(title: "", time: "April 26, Sat", poolType: "", cellType: .Date)
        var c6 = VolunteerModel(title: str, time: "12.00 pm", poolType: "Drop-off", cellType: .Normal)
        var c7 = VolunteerModel(title: str, time: "1.00 pm", poolType: "Pick-up", cellType: .Normal)
        
        var c8 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c9 = VolunteerModel(title: "", time: "May 1, Fri", poolType: "", cellType: .Date)
        var c10 = VolunteerModel(title: str, time: "12.00 pm", poolType: "Drop-off", cellType: .Normal)
        var c11 = VolunteerModel(title: str, time: "1.00 pm", poolType: "Pick-up", cellType: .Normal)
        tableData = [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11]
    }
    
    func setupNavigationBar() {
        self.title = "Volunteer"
        var leftButton = UIBarButtonItem(title: "Location", style: .Plain, target: self, action: "locationButtonClick")
        var rightButton = UIBarButtonItem(title: "next", style: .Plain, target: self, action: "nextButtonClick")
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func locationButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var vc = vcWithID("InviteParentsVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(tableData.count)
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = tableData[indexPath.row]
        if model.cellType == .Empty {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.cellType == .Normal {
            let cell = tableView.cellWithID("VolunteerCell", indexPath) as! VolunteerCell
            cell.timeLabel.text = model.timeString
            cell.poolTypeLabel.text = model.poolTypeString
            cell.driverTitleLabel.text = model.titleString
            return cell
        } else if model.cellType == .Date {
            let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
            cell.timeLabel.text = model.timeString
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = tableData[indexPath.row]
        if model.cellType == .Empty { return 20.0 }
        else if model.cellType == .Normal { return 70.0 }
        else if model.cellType == .Date { return 40.0}
        else { return 50.0 }
    }
}
