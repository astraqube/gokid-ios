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
    var userLoggedIn = false

    var userName = "Unknown"
    var userFirstName = "Unknown"
    var userLastName = "Unknown"
    var userTeamName = "Unknown Team"
    var userEmail = "Unknown"
    var userProfileImage: UIImage?
    
    var userHomeAdress: String?
    var recentAddressTitles = [String]()
    var recentAddress = [String]()
    
    override init() {
        super.init()
        initForRecentAddress()
    }
    
    func initForRecentAddress() {
        recentAddressTitles.append("Apple")
        recentAddress.append("95014 Cupertinuo CA United States")
        recentAddressTitles.append("GreenWhich School")
        recentAddress.append("88 Rivington Street, GreenWich, Conneticuit 12014")
    }
}





