//
//  CalendarVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class CalendarVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = [CalendarModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavBar() {
        setNavBarTitle("GoKids")
        setNavBarLeftButtonTitle("Menu", action: "menuButtonClick")
        setNavBarRightButtonTitle("Create", action: "createButtonClicked")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        dataSource = dataManager.fakeCalendarData()
        tableView.reloadData()
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func createButtonClicked() {
        var vc = vcWithID("BasicInfoVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func menuButtonClick() {
        self.navigationController?.viewDeckController.toggleLeftViewAnimated(true)
    }
    
    // MARK: TableView DataSource and Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = dataSource[indexPath.row]
        switch model.cellType {
        case .Notification:
            return configNotificationCell(indexPath, model)
        case .Time:
            return configCalendarDateCell(indexPath, model)
        case .Add:
            return configCalendarAddCell(indexPath, model)
        case .Normal:
            return configCalendarCell(indexPath, model)
        default:
            println("Unknown cell")
            return UITableViewCell()
        }
    }
    
    // MARK: Construct TableView Cells
    // --------------------------------------------------------------------------------------------
    
    func configNotificationCell(ip: NSIndexPath, _ model: CalendarModel) -> CalendarNotificationCell {
        var cell = tableView.cellWithID("CalendarNotificationCell", ip) as! CalendarNotificationCell
        cell.titleLabel.text = model.notification
        return cell
    }
    
    func configCalendarCell(ip: NSIndexPath, _ model: CalendarModel) -> CalendarCell {
        var cell = tableView.cellWithID("CalendarCell", ip) as! CalendarCell
        cell.nameLabel.text = model.poolname
        cell.timeLabel.text = model.pooltime
        cell.typeLabel.text = model.poolType
        cell.driverLabel.text = model.poolDriver
        return cell
    }
    
    func configCalendarDateCell(ip: NSIndexPath, _ model: CalendarModel) -> CalendarDateCell {
        var cell = tableView.cellWithID("CalendarDateCell", ip) as! CalendarDateCell
        cell.dateLabel.text = model.date
        return cell
    }
    
    func configCalendarAddCell(ip: NSIndexPath, _ model: CalendarModel) -> CalendarAddCell {
        var cell = tableView.cellWithID("CalendarAddCell", ip) as! CalendarAddCell
        return cell
    }
    
    // MARK: UITableView Delegate
    // --------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var model = dataSource[indexPath.row]
        switch model.cellType {
        case .Notification:
            return 83.0
        case .Time:
            return 39.0
        case .Add:
            return 224.0
        case .Normal:
            return 63.0
        default:
            return 50.0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
