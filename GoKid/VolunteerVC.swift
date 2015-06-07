//
//  VolunteerVC.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/4/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class VolunteerVC: BaseVC, UITableViewDelegate, UITableViewDataSource {

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
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func locationButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        var vc = vcWithID("InviteParentsVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkButtonClickHandler(cell: VolunteerCell, button: UIButton) {
        if let row = tableView.indexPathForCell(cell)?.row {
            if userManager.userLoggedIn == false {
                animatShowSignupVC()
            } else {
                showActionSheet(cell)
            }
        }
    }
    
    // MARK: TableView DataSource Method
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
            cell.checkButtonHandler = checkButtonClickHandler
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
    
    // MARK: Signin Signup
    // --------------------------------------------------------------------------------------------
    
    var signupVC: SignUpVC!
    func animatShowSignupVC() {
        signupVC = vcWithID("SignUpVC") as! SignUpVC
        signupVC.view.alpha = 0.0
        
        // view controller operations
        navigationController?.addChildViewController(signupVC)
        navigationController?.view.addSubview(signupVC.view)
        signupVC.didMoveToParentViewController(navigationController)
        signupVC.signinButtonHandler = signupToSignin
        
        // animation
        signupVC.view.alphaAnimation(1.0, duration: 0.5, completion: nil)
    }
    
    func signupToSignin() {
        signupVC.view.alphaAnimation(0.0, duration: 0.4) { (anim, finished) in
            
            self.signupVC.willMoveToParentViewController(nil)
            self.signupVC.view.removeFromSuperview()
            self.signupVC.removeFromParentViewController()
            
            withDelay(0.2) {
                var vc = vcWithID("SignInVC") as! SignInVC
                vc.signinSuccessHandler = self.signinSuccessHandler
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func signinSuccessHandler() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Action Sheet
    // --------------------------------------------------------------------------------------------
    
    func showActionSheet(cell: VolunteerCell) {
        let button1 = UIAlertAction(title: "Volunteer", style: .Default) { (alert) in
            cell.checkButton.imageView?.image = userManager.userProfileImage
        }
        let button2 = UIAlertAction(title: "Volunteer Every Sunday", style: .Default) { (alert) in
        }
        let button3 = UIAlertAction(title: "Volunteer All Drop-off", style: .Default) { (alert) in
        }
        let button4 = UIAlertAction(title: "Volunteer Every Day", style: .Default) { (alert) in
        }
        let button5 = UIAlertAction(title: "Assign team member", style: .Default) { (alert) in
        }
        let button6 = UIAlertAction(title: "Cancle", style: .Cancel) { (alert) in
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(button1)
        alert.addAction(button2)
        alert.addAction(button3)
        alert.addAction(button4)
        alert.addAction(button5)
        alert.addAction(button6)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}






