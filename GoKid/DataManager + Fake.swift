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
            "CarpoolEditVC": true,
            "CarpoolSucceedVC": true,
            "ContactPickerVC": true,
            "InviteParentsVC": true,
            "VolunteerVC": true,
            "LocationInputVC": true,
            "LocationVC": true,
            "FrequencyPickerFormVC": true,
            "TimeAndDateFormVC": true,
            "BasicInfoVC": true,
        ]
        var main = [
            "InviteConfirmVC": true,
            // "PhoneVerifyVC": true,
            // "Phone_VC": true,
            "PlacePickerVC": true,
            "KidAboutYouVC": true,
            "CalendarVC": true,
            "CarpoolListVC": true,
            "MenuVC": true,
            "MainStackVC": true,
            "InviteRelationshipVC": true,
            "InviteeListVC": true,
            "YourKidVC": true
        ]
        var teamAccount = [
            // "AddTeamMemberVC": true,
            "MemberProfileVC": true,
            "TeamAccountVC": true
        ]
        
        var login = [
            "InviteInfoVC": true,
            "SignUpVC": true,
            "SignInVC": true,
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
