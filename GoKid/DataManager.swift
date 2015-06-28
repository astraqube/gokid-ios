//
//  DataManager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/7/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

struct SignupForm {
    var passwordConfirm = ""
    var password = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    var role = ""
}

class DataManager: NSObject {
    
    var userManager = UserManager.sharedInstance
    var imageManager = ImageManager.sharedInstance
    var baseURL = "https://gokid.devon.io"
    typealias completion = ((Bool, String)->())
    
    // MARK: Singleton
    class var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        return Static.instance
    }
    
    func invite(phoneNumbers: [String], carpoolID: Int, comp: completion) {
        var url = baseURL + "/api/invites"
        var invite = ["carpool_id": String(carpoolID), "phone_numbers": phoneNumbers]
        var map = ["invite": invite]
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("invite success")
            comp(true, "")
        }) { (op, error) in
            println("invite failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func managerWithToken() -> AFHTTPRequestOperationManager {
        var token = userManager.userToken
        var manager = AFHTTPRequestOperationManager()
        manager.requestSerializer.setValue("token " + token, forHTTPHeaderField: "Authorization")
        return manager
    }
    
    func handleRequestError(op: AFHTTPRequestOperation?, error: NSError?, comp: completion) {
        var errorStr = constructErrorString(op, error: error)
        println(errorStr)
        comp(false, errorStr)
    }
    
    func handleUserResuestError(op: AFHTTPRequestOperation?, error: NSError?, comp: UserCompletion) {
        var errorStr = constructErrorString(op, error: error)
        println(errorStr)
        comp(false, errorStr, nil)
    }
    
    func constructErrorString(op: AFHTTPRequestOperation?, error: NSError?) -> String {
        var opErrorStr = ""
        var nsErrorStr = ""
        if let data = op?.responseData {
            opErrorStr = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        }
        if let str = error?.localizedDescription {
            nsErrorStr = str
        }
        var errorStr = opErrorStr + " " + nsErrorStr
        return errorStr
    }
}
