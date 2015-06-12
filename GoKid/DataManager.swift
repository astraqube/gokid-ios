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
    
    func signin(email: String, password: String, comp: completion) {
        var url = baseURL + "/api/sessions"
        var map = [
            "email": email,
            "password": password
        ]
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("Login success")
            self.userManager.setWithJsonReponse(JSON(obj))
            self.userManager.userLoggedIn = true
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            println("login failed")
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func signup(signupForm:SignupForm, comp: completion) {
        var url = baseURL + "/api/users"
        var arr = [
            "role": signupForm.role,
            "email": signupForm.email,
            "password": signupForm.password,
            "last_name": signupForm.lastName,
            "first_name": signupForm.firstName,
            "password_confirmation": signupForm.passwordConfirm
        ]
        var map = ["user": arr]
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("Create user success")
            self.userManager.setWithJsonReponse(JSON(obj))
            self.userManager.userLoggedIn = true
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            println("create user failed")
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func fbSignin(comp: completion) {
        var fbtoken = FBSDKAccessToken.currentAccessToken().tokenString
        if fbtoken == nil {
            comp(false, "Cannot find FBToken")
            return
        }
        
        var url = baseURL + "/api/sessions"
        var map = ["fb_token": fbtoken]
        
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("fbSignin user success")
            println(obj)
            self.userManager.setWithJsonReponse(JSON(obj))
            self.userManager.userLoggedIn = true
            self.userManager.useFBLogIn = true
            onMainThread() {
                self.postNotification("SignupFinished")
                comp(true, "")
            }
        }) { (op, error) in
            println("fbSignin user failed")
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func fbSignup(fbtoken: String, comp: completion) {
        var url = baseURL + "/api/users"
        var map = ["fb_token": fbtoken]
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("fbSignup user success")
            self.userManager.setWithJsonReponse(JSON(obj))
            self.userManager.useFBLogIn = true
            self.userManager.userLoggedIn = true
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            var errorStr = self.constructErrorStr(op, error: error)
            println(errorStr)
            comp(false, errorStr)
        }
    }
    
    func createCarpool(name: String, comp: completion) {
        var url = baseURL + "/api/carpools"
        var name = ["name": name]
        var map = ["carpool": name]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
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
        var invite = ["carpool+id": carpoolID, "phone_numbers": phoneNumbers]
        var map = ["invite": invite]
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
