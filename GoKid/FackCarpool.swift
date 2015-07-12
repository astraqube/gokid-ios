
// This file is unused code for now, I keep it because we may add it back in the future


//class func arrayOfFakeVolunteerEventsFromOccurrences(json: JSON, _ name: String) -> [CalendarModel] {
//    var arr = [CalendarModel]()
//    for (index: String, subJson: JSON) in json {
//        var carpool = CalendarModel(fakeList: subJson)
//        carpool.poolname = name
//        println(carpool.poolType)
//        println(carpool.poolDate)
//        arr.append(carpool)
//    }
//    return arr
//}


//func getFakeVolunteerList(model: CarpoolModel, comp: completion) {
//    var url = baseURL + "/api/carpools/temp-schedule"
//    var schedule = [
//        "dropoff_at": model.dropOffTime!.iso8601String(),
//        "pickup_at": model.pickUpTime!.iso8601String(),
//        "starts_at": model.startDate!.iso8601String(),
//        "ends_at": model.endDate!.iso8601String(),
//        "days_occuring": model.occurence!,
//        "time_zone": "Pacific Time (US & Canada)",
//    ]
//    var map = [
//        "schedule": schedule
//    ]
//    println(map)
//    var manager = managerWithToken()
//    manager.POST(url, parameters:map , success: { (op, obj) in
//        println("getFakeVolunteerList success")
//        var json = JSON(obj)
//        println(json)
//        var events = CalendarModel.arrayOfFakeVolunteerEventsFromOccurrences(json["carpools"], model.name)
//        self.userManager.fakeVolunteerEvents = events
//        comp(true, "")
//        }) { (op, error) in
//            println("getFakeVolunteerList failed")
//            self.handleRequestError(op, error: error, comp: comp)
//    }
//}


//func handleGetFakeVolunteerList(success: Bool, errorStr: String) {
//    LoadingView.dismiss()
//    if success {
//        dataSource = processRawCalendarEvents(userManager.fakeVolunteerEvents)
//        reloadWithDataSourceOnMainThread()
//    } else {
//        self.showAlert("Fail to fecth unregistered volunteer list", messege: errorStr, cancleTitle: "OK")
//    }
//}


// registerForNotification("SignupFinished", action: "fetchDataAfterLogin")


//func signinSuccessHandler() {
//    navigationController?.popViewControllerAnimated(true)
//    fetchDataAfterLogin()
//}
//
//func fetchDataAfterLogin() {
//    LoadingView.showWithMaskType(.Black)
//    dataManager.createCarpool(userManager.currentCarpoolModel, comp: handleCreateCarpoolSuccess)
//}
//
//func handleCreateCarpoolSuccess(success: Bool, errorStr: String) {
//    if success {
//        tryLoadTableData()
//    } else {
//        LoadingView.dismiss()
//        self.showAlert("Fail to create carpool", messege: errorStr, cancleTitle: "OK")
//    }
//}


//func signupToSignin() {
//    signupVC.view.alphaAnimation(0.0, duration: 0.4) { (anim, finished) in
//        self.signupVC.view.removeFromSuperview()
//        withDelay(0.2) {
//            var vc = vcWithID("SignInVC") as! SignInVC
//            vc.signinSuccessHandler = self.signinSuccessHandler
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//}

//// MARK: Signin Signup
//// --------------------------------------------------------------------------------------------
//
//var signupVC: SignUpVC!
//func animatShowSignupVC() {
//    signupVC = vcWithID("SignUpVC") as! SignUpVC
//    signupVC.view.alpha = 0.0
//    
//    // view controller operations
//    navigationController?.view.addSubview(signupVC.view)
//    signupVC.signinButtonHandler = signupToSignin
//    
//    // animation
//    signupVC.view.alphaAnimation(1.0, duration: 0.5, completion: nil)
//}








































































