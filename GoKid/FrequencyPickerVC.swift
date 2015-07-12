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
    var dataSource = [[FrequencyModel]]()
    var headerViews = [FrequencyHeader]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        setupTableViewData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
            var monday    = FrequencyModel("Monday",    1, false)
            var tuesday   = FrequencyModel("Tuesday",   2, false)
            var wednesday = FrequencyModel("Wednesday", 3, false)
            var thursday  = FrequencyModel("Thursday",  4, false)
            var friday    = FrequencyModel("Friday",    5, false)
            var saturday  = FrequencyModel("Saturday",  6, false)
            var sunday    = FrequencyModel("Sunday",    0, false)
            
            var data = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
            if let occ = userManager.currentCarpoolModel.occurence {
                println(occ)
                for i in occ {
                    data[i].selected = true
                }
            }
            
            data = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
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
        navigationController?.popViewControllerAnimated(true)
        userManager.currentCarpoolModel.occurence = getOccurence()
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
        var model = dataSource[indexPath.section][indexPath.row]
        var cell = tableView.cellWithID("FrequencyCell", indexPath) as! FrequencyCell
        cell.timeLabel.text = dataSource[indexPath.section][indexPath.row].name
        if model.selected {
            cell.checkImageView.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.checkImageView.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var model = dataSource[indexPath.section][indexPath.row]
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! FrequencyCell
        model.selected = !model.selected
        cell.setChecked(model.selected)
    }
    
    func headerViewClicked(index: Int) {
        
    }
    
    // MARK: TableView DataSource
    // --------------------------------------------------------------------------------------------
    
    func getOccurence() -> [Int] {
        var occ = [Int]()
        for section in dataSource {
            for item in section {
                if item.selected {
                    occ.append(item.num)
                }
            }
        }
        return occ
    }
}
