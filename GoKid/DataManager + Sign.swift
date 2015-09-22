//
//  File.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import AFNetworking
import SwiftyJSON

struct SignupForm {
    var passwordConfirm = ""
    var password = ""
    var phoneNum = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    var role = ""
    var image : UIImage?
}

extension DataManager {
    
    func signin(email: String, password: String, comp: completion) {
        let url = baseURL + "/api/sessions"
        let map = [
            "email": email,
            "password": password
        ]
        let manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("signin success", terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            print("signin failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func signup(signupForm:SignupForm, comp: completion) {
        let url = baseURL + "/api/users"
        var arr = [
            "email": signupForm.email,
            "password": signupForm.password,
            "last_name": signupForm.lastName,
            "first_name": signupForm.firstName,
            "password_confirmation": signupForm.passwordConfirm
        ]
        if signupForm.phoneNum != "" {
            arr["phone_number"] = signupForm.phoneNum
        } else {
            arr["phone_number"] = nil
        }
        let map = ["user": arr]
        let manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("signup success", terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            print("signup failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func fbSignin(comp: completion) {
        let fbtoken = FBSDKAccessToken.currentAccessToken().tokenString
        if fbtoken == nil {
            comp(false, "Cannot find FBToken")
            return
        }
        
        let url = baseURL + "/api/sessions"
        let map = ["fb_token": fbtoken]
        
        let manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("fbSignin user success", terminator: "")
            print(FBSDKAccessToken.currentAccessToken().tokenString, terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            self.userManager.useFBLogIn = true
            self.fbUploadProfileImage() { (result, error) -> () in
                onMainThread() {
                    self.postNotification("SignupFinished")
                }
                comp(result, error)
            }

            onMainThread() {
                self.postNotification("SignupFinished")
                comp(true, "")
            }
        }) { (op, error) in
            print("fbSignin user failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func fbUploadProfileImage(comp: completion) {
        let fbUserID = FBSDKAccessToken.currentAccessToken().userID
        let url = "http://graph.facebook.com/\(fbUserID)/picture?type=large"

        imageManager.getImageAtURL(url) { (image, error) -> () in
            if image != nil {
                print("fbUploadProfileImage \(url)", terminator: "")
                self.upLoadImage(image!, comp: comp)
            } else {
                print("fbUploadProfileImage failed", terminator: "")
                comp(true, "") // do not disturb the process
            }
        }
    }

    func upLoadImage(image: UIImage, comp: completion) {
        
        let urlStr = baseURL + "/api/me/upload"
        let url = NSURL(string: urlStr)!
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let token = userManager.userToken
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token " + token, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        request.HTTPBody = imageData

        let op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.setCompletionBlockWithSuccess({ (op, obj) in
            print("succeess to upload image", terminator: "")
            var json = JSON(obj)
            self.userManager.info.thumURL = json["avatar"]["thumb_url"].stringValue
            self.userManager.saveUserInfo()
            self.imageManager.removeDiskCacheForURL(self.userManager.info.thumURL)
            comp(true, "")
        }, failure: { (op, error) in
            self.handleRequestError(op, error: error, comp: comp)
        })
        NSOperationQueue.mainQueue().addOperation(op)
    }
    
    func updateUser(signupForm:SignupForm, comp: completion) {
        let url = baseURL + "/api/me"
        var arr = [
            "role": signupForm.role.lowercaseString,
            "email": signupForm.email,
            "password": signupForm.password,
            "last_name": signupForm.lastName,
            "first_name": signupForm.firstName,
        ]
        if signupForm.phoneNum != "" {
            arr["phone_number"] = signupForm.phoneNum
        } else {
            arr["phone_number"] = nil
        }
        let map = ["user": arr]
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("update user success", terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            print("update user failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updatePhoneNumber(phone: String, comp: completion) {
        let url = baseURL + "/api/me"
        let map = ["user": ["phone_number": phone]]
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("update phone success", terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            comp(true, "")
        }) { (op, error) in
            print("update phone failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateUserRole(role: String, comp: completion) {
        let url = baseURL + "/api/me"
        let arr = [
            "role": role.lowercaseString
        ]
        let map = ["user": arr]
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateUserRole success", terminator: "")
            self.userManager.setWithJsonReponse(JSON(obj))
            comp(true, "")
        }) { (op, error) in
            print("updateUserRole failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func resetPassword(email: String, comp: completion) {
        let url = "\(baseURL)/users/password"
        let manager = managerWithToken()
        manager.POST(url, parameters: ["email": email], success: { (op, obj) in
            print("resetPassword success", terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("resetPassword failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
