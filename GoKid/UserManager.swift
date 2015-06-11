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
  
  var over18: Bool = false
  var useFBLogIn = false
  var userLoggedIn = false
  var userFirstTimeLogin = false
  
  var userName = "Unknown"
  var userFirstName = "Unknown"
  var userLastName = "Unknown"
  var userRole = "Unknown"
  var userTeamName = "Unknown Team"
  var userEmail = "Unknown"
  var userPhoneNumber = "Unknown"
  var userProfileImage: UIImage?
  
  var currentChoosenDate: String?
  var currentChossenStartTime: String?
  var currentChoosenEndTime: String?
  
  var token = ""
  
  var userHomeAdress: String?
  var recentAddressTitles = [String]()
  var recentAddress = [String]()
  
  var teamMembers = [TeamMemberModel]()
  
  var ud = NSUserDefaults.standardUserDefaults()
  
  override init() {
    super.init()
    initForRecentAddress()
    initForTeamMembers()
    getValueFromUserDefaults()
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
    token = user["token"].stringValue
  }
  
  
  // MARK: User Defaults
  // --------------------------------------------------------------------------------------------
  
  func getValueFromUserDefaults() {
    if let v = ud.valueForKey("useFBLogIn") as? Bool {
      useFBLogIn = v
    }
    if let v = ud.valueForKey("userFirstTimeLogin") as? Bool {
      userFirstTimeLogin = v
    }
  }
  
  func saveToUserDefault() {
    ud.setValue(useFBLogIn, forKey: "useFBLogIn")
    ud.setValue(userFirstTimeLogin, forKey: "userFirstTimeLogin")
  }

}





