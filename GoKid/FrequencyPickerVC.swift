//
//  FrequencyPickerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/3/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

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
        var sections = 10
        
        for i in 0..<sections {
            var data = [String]()
            for j in 0...4 {
                data.append("Cell " + String(j))
            }
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
        println(indexPath)
    }
    
    func headerViewClicked(index: Int) {
        println(index)
    }
}
