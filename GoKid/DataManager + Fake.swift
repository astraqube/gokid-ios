//
//  DataManager Fack.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

extension DataManager {
    
    func sbViewControllerList() -> [String:[String:Bool]] {
        var carpool = [
            "InviteConfirmTimesVC": true,
            "CarpoolEditVC": true,
            "CarpoolSucceedVC": true,
            "ContactPickerVC": true,
            "InviteParentsVC": true,
            "VolunteerVC": true,
            "LocationInputVC": true,
            "LocationVC": true,
            "FrequencyPickerFormVC": true,
            "TimeAndDateFormVC": true,
            "EditTimeAndDateFormVC": true,
            "BasicInfoVC": true,
        ]
        var main = [
            "InviteConfirmVC": true,
            "PlacePickerVC": true,
            "CalendarVC": true,
            "CarpoolListVC": true,
            "MenuVC": true,
            "MainStackVC": true,
            "InviteRelationshipVC": true,
            "YourKidVC": true
        ]
        var teamAccount = [
            "MemberProfileVC": true,
            "TeamAccountVC": true
        ]
        
        var login = [
            "InviteInfoVC": true,
            "SignUpVC": true,
            "SignInVC": true,
            "LoginDigitsVC": true,
            "PhoneNumberVC": true
        ]
        var onboard = [
            "LastOnboardVC": true
        ]        
        var navMap = [
            "DetailMapVC": true
        ]
        var map = [
            "Carpool" : carpool,
            "Main" : main,
            "TeamAccount": teamAccount,
            "Login": login,
            "Onboard": onboard,
            "NavMap" : navMap
        ]
        return map
    }
}
