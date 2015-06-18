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
    var baseURL = "https://gokid.devon.io"
    typealias completion = ((Bool, String)->())
    
    // MARK: Singleton
    class var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        return Static.instance
    }
    
    func createCarpool(name: String, comp: completion) {
        var url = baseURL + "/api/carpools"
        var name = ["name": name]
        var map = ["carpool": name]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpool = carpool
            println("create carpool success")
            println(obj)
            comp(true, "")
        }) { (op, error) in
            println("create carpool failed")
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func getCarpools(comp: completion) {
        var url = baseURL + "/api/carpools"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getCarpool success")
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpool = carpool
            comp(true, "")
        }) { (op, error) in
            println("get carpool failed")
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
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
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func managerWithToken() -> AFHTTPRequestOperationManager {
        var token = userManager.userToken
        println("user token " + token)
        var manager = AFHTTPRequestOperationManager()
        manager.requestSerializer.setValue("token " + token, forHTTPHeaderField: "Authorization")
        return manager
    }
    
    func constructErrorStr(op: AFHTTPRequestOperation?, error: NSError?) -> String {
        var opStr = ""
        var errorStr = ""
        if let data = op?.responseData {
            opStr = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        }
        if let str = error?.localizedDescription {
            errorStr = str
        }
        var final = opStr + " " + errorStr
        return final
    }
}
