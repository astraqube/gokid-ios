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
    
    var userProfileImage: UIImage?
    var info = TeamMemberModel()
    var teamMembers = [TeamMemberModel]()
    var calendarEvents = [CalendarModel]()
    
    
    var updatedMember = TeamMemberModel()
    
    var currentCarpoolName: String = ""
    var currentCarpoolKidName: String = ""
    var currentChoosenDate: String?
    var currentChossenStartTime: String?
    var currentChoosenEndTime: String?
    var currentCarpoolModel = CarpoolModel()
    
    var userHomeAdress: String?
    var recentAddressTitles = [String]()
    var recentAddress = [String]()
    
    let documentPath = NSHomeDirectory() + "/Documents/"
    var ud = NSUserDefaults.standardUserDefaults()
    
    override init() {
        super.init()
        initForRecentAddress()
        initForTeamMembers()
        loadUserInfo()
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
        info = TeamMemberModel()
        info.firstName = user["first_name"].stringValue
        info.lastName = user["last_name"].stringValue
        info.email = user["email"].stringValue
        info.role = user["role"].stringValue
        info.cellType = .EditUser
        
        if let teamID = json["teams"][0]["id"].int {
            info.teamID = teamID
        }
        if let imageURL = user["avatar"]["thumb_url"].string {
            info.thumURL = imageURL
        }
        if let passWord = user["generated_password"].string {
            info.passWord = passWord
        }
        if let passWord = user["password"].string {
            info.passWord = passWord
        }
        userToken = user["token"].stringValue
        saveUserInfo()
    }
    
    
    // MARK: User Defaults
    // --------------------------------------------------------------------------------------------
    
    func saveUserInfo() {
        var avatar = [
            "thumb_url": info.thumURL
        ]
        var teams = [
            ["id": info.teamID]
        ]
        var userInfo = [
            "first_name": info.firstName,
            "password" : info.passWord,
            "last_name": info.lastName,
            "email": info.email,
            "token": userToken,
            "role": info.role,
            "avatar": avatar
        ]
        var map = [
            "user": userInfo,
            "teams": teams
        ]
        if let data = JSON(map).rawData(options: .PrettyPrinted, error: nil) {
            var path = documentPath + "user_info"
            data.writeToFile(path, atomically: true)
        } else {
            println("\(__FUNCTION__) + cannot save user info + \(map)" )
        }
    }
    
    func loadUserInfo() {
        var path = documentPath + "user_info"
        if let data = NSData(contentsOfFile: path) {
            var json = JSON(data: data)
            setWithJsonReponse(json)
        }
    }
    
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
        set {
            ud.setValue(newValue, forKey: "userToken")
        }
        get {
            if let v = ud.valueForKey("userToken") as? String { return v }
            else { return "" }
        }
    }
}





