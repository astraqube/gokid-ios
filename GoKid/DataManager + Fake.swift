//
//  DataManager Fack.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

extension DataManager {
    
    func fakeVolunteerData() -> [VolunteerModel] {
        var date = "April 24, Fri"
        var pickupTime = "12.00 pm"
        var dropoffTime = "1.00 pm"
        
        var model = userManager.currentCarpoolModel
        if let str = model.startDate?.dateString() { date = str }
        if let str = model.pickUpTime?.timeString() { pickupTime = str }
        if let str = model.dropOffTime?.timeString() { dropoffTime = str }
        
        var str = "Volunteer as Driver"
        var c0 = VolunteerModel(title: "", time: "", poolType: "", cellType: .Empty)
        var c1 = VolunteerModel(title: "", time: date, poolType: "", cellType: .Date)
        var c2 = VolunteerModel(title: str, time: dropoffTime, poolType: "Drop-off", cellType: .Normal)
        var c3 = VolunteerModel(title: str, time: pickupTime, poolType: "Pick-up", cellType: .Normal)
        
        if userManager.volunteerEvents.count >= 2 {
            var v0 = userManager.volunteerEvents[0]
            var v1 = userManager.volunteerEvents[1]
            
            c3.carpoolID = v0.carpoolID
            c3.occrenceID = v0.occrencID
            
            c2.carpoolID = v1.carpoolID
            c2.occrenceID = v1.occrencID
        }
        return [c0, c1, c2, c3]
    }
    
    func fakeTimeAndDateTableViewData(vc: TimeAndDateVC) {
        var c1 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c2 = TDCellModel(title: "Start date",      value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c3 = TDCellModel(title: "Repeat",          value: "",       switchValue: false, type: .Switcher, action: .None)
        var c4 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c5 = TDCellModel(title: vc.eventStart,     value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c6 = TDCellModel(title: vc.eventEnd,       value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c7 = TDCellModel(title: "One-way carpool", value: "",       switchValue: false, type: .Switcher, action: .None)
        vc.oneCarpoolModle = c7
        vc.dateModel = c2
        vc.startTimeModel = c5
        vc.endTimeModel = c6
        vc.dataSource = [c1, c2, c3, c4, c5, c6, c7]
    }
    
    func fakeTimeAndDateRepetedTableViewData(vc: TimeAndDateVC) {
        var c1 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c2 = TDCellModel(title: "Start Date ",     value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c3 = TDCellModel(title: "End Date ",       value: "Select", switchValue: true,  type: .Text,     action: .ChooseDate)
        var c4 = TDCellModel(title: "Frequency",       value: ">",      switchValue: true,  type: .Text,     action: .None)
        var c5 = TDCellModel(title: "Repeat",          value: "",       switchValue: true,  type: .Switcher, action: .None)
        var c6 = TDCellModel(title: "",                value: "",       switchValue: true,  type: .Empty,    action: .None)
        var c7 = TDCellModel(title: vc.eventStart,     value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c8 = TDCellModel(title: vc.eventEnd,       value: "Select", switchValue: true,  type: .Text,     action: .ChooseTime)
        var c9 = TDCellModel(title: "One-way carpool", value: "",       switchValue: false, type: .Switcher, action: .None)
        vc.oneCarpoolModle = c9
        vc.dataSource = [c1, c2, c3, c4, c5, c6, c7, c8, c9]
    }
    
    func sbViewControllerList() -> [String:[String:Bool]] {
        var carpool = [
            "CarpoolSucceedVC": true,
            "ContactPickerVC": true,
            "InviteParentsVC": true,
            "VolunteerVC": true,
            "LocationInputVC": true,
            "LocationVC": true,
            "FrequencyPickerVC": true,
            "TimeAndDateVC": true,
            "BasicInfoVC": true,
        ]
        var main = [
            "InviteConfirmVC": true,
            "PhoneVerifyVC": true,
            "Phone_VC": true,
            "PlacePickerVC": true,
            "KidAboutYouVC": true,
            "CalendarVC": true,
            "MenuVC": true,
            "MainStackVC": true,
            "InviteRelationshipVC": true,
            "InviteeListVC": true,
            "YourKidVC": true
        ]
        var teamAccount = [
            "AddTeamMemberVC": true,
            "MemberProfileVC": true,
            "TeamAccountVC": true
        ]
        
        var login = [
            "InviteInfoVC": true,
            "SignUpVC": true,
            "SignInVC": true
        ]
        var onboard = [
            "LastOnboardVC": true
        ]        
        var map = [
            "Carpool" : carpool,
            "Main" : main,
            "TeamAccount": teamAccount,
            "Login": login,
            "Onboard": onboard
        ]
        return map
    }
}
