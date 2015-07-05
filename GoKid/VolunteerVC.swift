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
    var dataSource = [CalendarModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        registerForNotification("SignupFinished", action: "fetchDataAfterLogin")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tryLoadTableData()
    }
    
    func setupNavigationBar() {
        var nav = navigationController as! ZGNavVC
        nav.addTitleViewToViewController(self)
        self.title = "Volunteer"
        self.subtitle = userManager.currentCarpoolName + " for " + userManager.currentCarpoolKidName
        setNavBarLeftButtonTitle("Location", action: "locationButtonClick")
        setNavBarRightButtonTitle("Next", action: "nextButtonClick")
    }
    
    // MARK: IBAction Method
    // --------------------------------------------------------------------------------------------
    
    func locationButtonClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func nextButtonClick() {
        if userManager.userLoggedIn {
            var vc = vcWithID("InviteParentsVC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            animatShowSignupVC()
        }
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
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var model = dataSource[indexPath.row]
        if model.cellType == .None {
            let cell = tableView.cellWithID("TDEmptyCell", indexPath) as! TDEmptyCell
            return cell
        } else if model.cellType == .Normal {
            let cell = tableView.cellWithID("VolunteerCell", indexPath) as! VolunteerCell
            cell.timeLabel.text = model.poolTimeStringWithSpace()
            cell.poolTypeLabel.text = model.poolType
            cell.checkButtonHandler = checkButtonClickHandler
            if model.poolDriver == "No Driver yet" { cell.driverTitleLabel.text = "Volunteer to Drive" }
            else { cell.driverTitleLabel.text = model.poolDriver }
            return cell
        } else if model.cellType == .Time {
            let cell = tableView.cellWithID("VolunteerTimeCell", indexPath) as! VolunteerTimeCell
            cell.timeLabel.text = model.poolDateStr
            cell.locationLabel.text = userManager.currentCarpoolModel.startLocation
            return cell
        } else {
            println("unknown tableview cell type")
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var model = dataSource[indexPath.row]
        switch model.cellType {
        case .None:
            return 20.0
        case .Normal:
            return 70.0
        case .Time:
            return 60.0
        default:
            return 50.0
        }
    }
    
    // MARK: Signin Signup
    // --------------------------------------------------------------------------------------------
    
    var signupVC: SignUpVC!
    func animatShowSignupVC() {
        signupVC = vcWithID("SignUpVC") as! SignUpVC
        signupVC.view.alpha = 0.0
        
        // view controller operations
        navigationController?.view.addSubview(signupVC.view)
        signupVC.signinButtonHandler = signupToSignin
        
        // animation
        signupVC.view.alphaAnimation(1.0, duration: 0.5, completion: nil)
    }
    
    func signupToSignin() {
        signupVC.view.alphaAnimation(0.0, duration: 0.4) { (anim, finished) in
            self.signupVC.view.removeFromSuperview()
            withDelay(0.2) {
                var vc = vcWithID("SignInVC") as! SignInVC
                vc.signinSuccessHandler = self.signinSuccessHandler
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func signinSuccessHandler() {
        navigationController?.popViewControllerAnimated(true)
        fetchDataAfterLogin()
    }
    
    func fetchDataAfterLogin() {
        LoadingView.showWithMaskType(.Black)
        dataManager.createCarpool(userManager.currentCarpoolModel, comp: handleCreateCarpoolSuccess)
    }
    
    func handleCreateCarpoolSuccess(success: Bool, errorStr: String) {
        if success {
            dataManager.getOccurenceOfCarpool(userManager.currentCarpoolModel.id, comp: handleGetVolunteerList)
        } else {
            LoadingView.dismiss()
            self.showAlert("Fail to create carpool", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    func handleGetVolunteerList(success: Bool, errorStr: String) {
        LoadingView.dismiss()
        if success {
            setupTableView()
        } else {
            self.showAlert("Fail to fetch vlounteer list", messege: errorStr, cancleTitle: "OK")
        }
    }
    
    // MARK: NetWork Create Carpool
    // --------------------------------------------------------------------------------------------
    
    func createCarpool() {
      var model = userManager.currentCarpoolModel
      dataManager.createCarpool(model) { (success, errorStr) in
        if success {
          var vc = vcWithID("InviteParentsVC")
          self.navigationController?.pushViewController(vc, animated: true)
        } else {
          self.showAlert("Alert", messege: "Cannot create Carpool " + errorStr, cancleTitle: "OK")
        }
      }
    }
    
    func tryLoadTableData() {
        if userManager.userLoggedIn {
            dataSource = processRawCalendarEvents(userManager.volunteerEvents)
        } else {
            dataSource = processRawCalendarEvents(userManager.fakeVolunteerEvents)
        }
        tableView.reloadData()
    }
    
    func processRawCalendarEvents(events: [CalendarModel]) -> [CalendarModel] {
        var data = [CalendarModel]()
        var lastDateStr = ""
        for event in events {
            if event.poolDateStr != lastDateStr {
                var dateCell = CalendarModel()
                dateCell.cellType = .Time
                dateCell.poolDateStr = event.poolDateStr
                data.append(dateCell)
                lastDateStr = event.poolDateStr
            }
            data.append(event)
        }
        return data
    }
}






