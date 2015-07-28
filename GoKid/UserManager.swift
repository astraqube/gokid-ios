//
//  UserManager.swift
//  WeRead
//
//  Created by Bingwen on 11/4/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

let RoleTypeCareTaker = "Caretaker"
let RoleTypeChild = "Child"
let RoleTypeMommy = "Mommy"
let RoleTypeDaddy = "Daddy"
let RoleTypeParent = "Parent"
let RoleTypeOther = "Other"

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
    var calendarEvents = [OccurenceModel]()
    var volunteerEvents = [OccurenceModel]()
    var fakeVolunteerEvents = [OccurenceModel]()
    var carpools = [CarpoolModel]()
    
    var updatedMember = TeamMemberModel()
    
    var currentChoosenDate: String?
    var currentChossenStartTime: String?
    var currentChoosenEndTime: String?
    var currentCarpoolModel = CarpoolModel()
    
    var userHomeAdress = ""
    var recentAddressTitles = [String]()
    var recentAddress = [String]()
    
    let documentPath = NSHomeDirectory() + "/Documents/"
    var ud = NSUserDefaults.standardUserDefaults()
    
    // this is for invite info VC, where take all the info,
    // but just check for his phone num and use this info to
    // register later
    var unregisteredUserInfo: SignupForm?
    // this is used for accept or decline the invitation
    var inviteID = 0
    // this is for invitation flow
    var inviterName = ""
    var inviteKidName = ""

    override init() {
        super.init()
        initForTeamMembers()
        loadUserInfo()
    }
    
    func initForTeamMembers() {
        teamMembers = [TeamMemberModel()]
    }
    
    func currentCarpoolDescription() -> String {
        return currentCarpoolModel.name + " for " + currentCarpoolModel.kidName
    }
    
    // use the info get from all team members
    func updateUserWithTeamMembersInfo(json: JSON) {
        info.phoneNumber = json["phone_number"].stringValue
        info.firstName = json["first_name"].stringValue
        info.lastName = json["last_name"].stringValue
        info.email = json["email"].stringValue
        info.role = json["role"].stringValue
        info.thumURL = json["avatar"]["thumb_url"].stringValue
        saveUserInfo()
    }
    
    func setWithJsonReponse(json: JSON) {
        var user = json["user"]
        info = TeamMemberModel()
        info.firstName = user["first_name"].stringValue
        info.lastName = user["last_name"].stringValue
        info.email = user["email"].stringValue
        info.role = user["role"].stringValue
        info.phoneNumber = user["phone_number"].stringValue
        info.userID = user["id"].intValue
        info.cellType = .EditUser
        
        if let arr = user["recentAddress"].arrayObject as? [String] {
            recentAddress = arr
        }
        if let arr = user["recentAddressTitle"].arrayObject as? [String] {
            recentAddressTitles = arr
        }
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

        self.userToken = user["token"].stringValue

        if self.userToken != "" {
            self.userLoggedIn = true
        } else {
            self.userLoggedIn = false
        }

        saveUserInfo()
    }
    
    
    // MARK: User Defaults
    // --------------------------------------------------------------------------------------------
    
    func saveUserInfo() {
        controlRecentAddressSize()
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
            "id": info.userID,
            "token": userToken,
            "role": info.role,
            "avatar": avatar,
            "recentAddress": recentAddress,
            "recentAddressTitle": recentAddressTitles,
            "phone_number": info.phoneNumber
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
        ud.synchronize()
    }
    
    func loadUserInfo() {
        var path = documentPath + "user_info"
        if let data = NSData(contentsOfFile: path) {
            var json = JSON(data: data)
            setWithJsonReponse(json)
        }
    }
    
    func controlRecentAddressSize() {
        if recentAddress.count > 15 {
            var data = [String]()
            for i in 0..<8 {
                data.append(recentAddress[i])
            }
            recentAddress = data
        }
        if recentAddressTitles.count > 15 {
            var data = [String]()
            for i in 0..<8 {
                data.append(recentAddressTitles[i])
            }
            recentAddressTitles = data
        }
    }

    func logoutUser() {
        self.userToken = ""
        self.info = TeamMemberModel()
        self.saveUserInfo()

        self.userLoggedIn = false
        self.useFBLogIn = false
        self.userFirstTimeLogin = true
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
            let v = ud.valueForKey("userToken") as? String
            if (v == nil || v == "") && self.userLoggedIn == false {
                self.postNotification("requestForUserToken")
                return ""
            } else {
                return v!
            }
        }
    }

    
    // this is very bad but devon insist we grop occrence by time
    // as a reault this cause weak connction between pickup and drop off
    // might be a bug in the future
    func groupedVolunteerEvents() -> [(OccurenceModel, OccurenceModel)] {
        var lastEvent = OccurenceModel()
        var data = [(OccurenceModel, OccurenceModel)]()
        for event in volunteerEvents {
            if event.occursAtStr == lastEvent.occursAtStr {
                data.append((lastEvent, event))
                continue
            }
            lastEvent = event
        }
        return data
    }
}





