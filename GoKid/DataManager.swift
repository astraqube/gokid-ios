//
//  DataManager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/7/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

typealias completion = ((Bool, String)->())
typealias ObjectCompletion = ((Bool, String, AnyObject?)->())

class DataManager: NSObject {
    
    var baseURL = "https://gokid.devon.io"
    var userManager = UserManager.sharedInstance
    var imageManager = ImageManager.sharedInstance
    
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
    
    func handleUserResuestError(op: AFHTTPRequestOperation?, error: NSError?, comp: ObjectCompletion) {
        var errorStr = constructErrorString(op, error: error)
        println(errorStr)
        comp(false, errorStr, nil)
    }
    
    
    let __debug__ = false
    func constructErrorString(op: AFHTTPRequestOperation?, error: NSError?) -> String {
        if __debug__ {
            return constructDebugErrorStr(op, error)
        } else {
            return constructReleaseErrorStr(op, error)
        }
    }
    
    func constructDebugErrorStr(op: AFHTTPRequestOperation?, _ error: NSError?) -> String {
        var opErrorStr = ""
        var nsErrorStr = ""
        if let data = op?.responseData { opErrorStr = String.fromData(data) }
        if let str = error?.localizedDescription { nsErrorStr = str }
        return opErrorStr + " " + nsErrorStr
    }
    
    func constructReleaseErrorStr(op: AFHTTPRequestOperation?, _ error: NSError?) -> String {
        if let data = op?.responseData {
            var json = JSON(data: data)
            println(json)
            var message = json["message"].stringValue
            if message != "" {
                return message
            }
        }
        return "Something went wrong..."
    }
}





