//
//  FrequencyPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class FrequencyModel {
    var name = ""
    var num = 0
    var selected = false
    
    init(_ name: String, _ num: Int, _ selected: Bool) {
        self.name = name
        self.num = num
        self.selected = selected
    }
}

class FrequencyPickerVC: BaseVC, UITableViewDataSource, UITableViewDelegate, STCollapseTableViewDelegate {
    
    @IBOutlet weak var tableView: STCollapseTableView!
    var dataSource = [[String]]()
    var headerViews = [FrequencyHeader]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupTableViewData()
    }
    
    func setupNavBar() {
        setNavBarTitle("Repeat")
        setNavBarLeftButtonTitle("Back", action: "backButtonClick")
        setNavBarRightButtonTitle("Done", action: "nextButtonClick")
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerClickDelegate = self
        tableView.exclusiveSections = false
    }
    
    func setupTableViewData() {
        var sections = 1
        
        for i in 0..<sections {
            var monday = FrequencyModel("Monday", 1, false)
            var tuesday = FrequencyModel("Tuesday", 2, false)
            var wednesday = FrequencyModel("Wednesday", 3, false)
            var thursday = FrequencyModel("Thursday", 4, false)
            var friday = FrequencyModel("Friday", 5, false)
            var saturday = FrequencyModel("Saturday", 6, false)
            var sunday = FrequencyModel("Sunday", 7, false)
            
            var data = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            dataSource.append(data)
        }
        
        for i in 0..<sections {
            var w = userManager.windowW
            var header = FrequencyHeader(frame: CGRectMake(0, 0, w, 40))
            header.timeLabel.text = "Every Week"
            headerViews.append(header)
        }
    }
    
    // MARK: IBAction Methods
    // --------------------------------------------------------------------------------------------
    
    func backButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        println("next button click")
    }
    
    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.cellWithID("FrequencyCell", indexPath) as! FrequencyCell
        cell.timeLabel.text = dataSource[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func headerViewClicked(index: Int) {
        println(index)
    }
}
