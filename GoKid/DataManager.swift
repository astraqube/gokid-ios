//
//  DataManager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/7/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    var baseURL = "https://gokid.devon.io"
    var userManager = UserManager.sharedInstance
    var imageManager = ImageManager.sharedInstance
    typealias completion = ((Bool, String)->())
    typealias UserCompletion = ((Bool, String, TeamMemberModel?)->())
    
    
    // MARK: Singleton
    class var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        return Static.instance
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
