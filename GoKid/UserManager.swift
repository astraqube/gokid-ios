//
//  UserManager.swift
//  WeRead
//
//  Created by Bingwen on 11/4/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

class UserManager: NSObject {
    
    // MARK: Singleton
    class var sharedInstance : UserManager {
        struct Static {
            static let instance : UserManager = UserManager()
        }
        return Static.instance
    }
    
    var windowH: CGFloat = 0
    var windowW: CGFloat = 0
    
    var userName = "Unknown"
    var userFirstName = "Unknown"
    var userLastName = "Unknown"
    var userRole = "Unknown"
    var userTeamName = "Unknown Team"
    var userEmail = "Unknown"
    var userPhoneNumber = "Unknown"
    var userProfileImage: UIImage?
    
    var currentCarpoolName: String = ""
    var currentCarpoolKidName: String = ""
    var currentChoosenDate: String?
    var currentChossenStartTime: String?
    var currentChoosenEndTime: String?
    
    
    var userHomeAdress: String?
    var recentAddressTitles = [String]()
    var recentAddress = [String]()
    
    var teamMembers = [TeamMemberModel]()
    var currentCarpool = CarpoolModel()
    
    
    var ud = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
        initForRecentAddress()
        initForTeamMembers()
    }
    
    func initForRecentAddress() {
        recentAddressTitles.append("Apple")
        recentAddress.append("1 Infinite Loop, Cupertino, CA 95014")
        recentAddressTitles.append("GreenWhich School")
        recentAddress.append("88 Rivington Street, Greenwich, CT 12014")
    }
    
    func initForTeamMembers() {
        teamMembers = [TeamMemberModel()]
    }
    
    func setWithJsonReponse(json: JSON) {
        var user = json["user"]
        userFirstName = user["first_name"].stringValue
        userLastName = user["last_name"].stringValue
        userRole = user["role"].stringValue
        userEmail = user["email"].stringValue
        userToken = user["token"].stringValue
    }
    
    
    // MARK: User Defaults
    // --------------------------------------------------------------------------------------------
    
    var over18: Bool {
        set { ud.setValue(newValue, forKey: "over18") }
        get {
            if let v = ud.valueForKey("over18") as? Bool { return v }
            else { return false }
        }
    }
    
    var useFBLogIn: Bool {
        set { ud.setValue(newValue, forKey: "useFBLogIn") }
        get {
            if let v = ud.valueForKey("useFBLogIn") as? Bool { return v }
            else { return false }
        }
    }
    
    var userLoggedIn: Bool {
        set { ud.setValue(newValue, forKey: "userLoggedIn") }
        get {
            if let v = ud.valueForKey("userLoggedIn") as? Bool { return v }
            else { return false }
        }
    }
    
    var userFirstTimeLogin: Bool {
        set { ud.setValue(newValue, forKey: "userFirstTimeLogin") }
        get {
            if let v = ud.valueForKey("userFirstTimeLogin") as? Bool { return v }
            else { return false }
        }
    }
    
    var userToken: String {
        set { ud.setValue(newValue, forKey: "userToken") }
        get {
            if let v = ud.valueForKey("userToken") as? String { return v }
            else { return "" }
        }
    }
}





