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
    typealias completion = ((Bool, String?)->())
    
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
            comp(true, nil)
        }) { (op, error) in
            println("login failed")
            var str = NSString(data: op.responseData, encoding: NSUTF8StringEncoding) as? String
            comp(false, str)
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
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, nil)
        }) { (op, error) in
            println("create user failed")
            var str = NSString(data: op.responseData, encoding: NSUTF8StringEncoding) as? String
            comp(false, str)
        }
    }
    
    func fbSignin() {
        
    }
    
    func fbSignup() {
        
    }
}
