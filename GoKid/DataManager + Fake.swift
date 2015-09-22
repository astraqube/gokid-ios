//
//  DataManager Fack.swift
//  
//
//  Created by Bingwen Fu on 6/21/15.
//
//

extension DataManager {
    
    func sbViewControllerList() -> [String:[String:Bool]] {
        let carpool = [
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
            "InviteesVC": true,
        ]
        let main = [
            "InviteConfirmVC": true,
            "PlacePickerVC": true,
            "CalendarVC": true,
            "CarpoolListVC": true,
            "MenuVC": true,
            "MainStackVC": true,
            "InviteRelationshipVC": true,
            "YourKidVC": true
        ]
        let teamAccount = [
            "MemberProfileVC": true,
            "TeamAccountVC": true
        ]
        
        let login = [
            "InviteInfoVC": true,
            "SignUpVC": true,
            "SignInVC": true,
            "PhoneNumberVC": true
        ]
        let onboard = [
            "LastOnboardVC": true
        ]        
        let navMap = [
            "DetailMapVC": true
        ]
        let map = [
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
