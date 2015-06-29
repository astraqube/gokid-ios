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
        registerForNotification("SignupFinished", action: "fetchDataAfterLogin")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableData = dataManager.fakeVolunteerData()
        tableView.reloadData()
    }
    
    func setupNavigationBar() {
        setNavBarTitle("Volunteer")
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
        switch model.cellType {
        case .Empty:
            return 20.0
        case .Normal:
            return 70.0
        case .Date:
            return 40.0
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
            dataManager.occurenceOfCarpool(userManager.currentCarpoolModel.id, comp: handleGetVolunteerList)
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
    
    // MARK: Create Carpool
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
}






