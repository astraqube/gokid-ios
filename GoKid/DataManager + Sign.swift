//
//  File.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/17/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

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
        var url = baseURL + "/api/sessions"
        var map = [
            "email": email,
            "password": password
        ]
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("signin success")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            println("signin failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func signup(signupForm:SignupForm, comp: completion) {
        var url = baseURL + "/api/users"
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
        var map = ["user": arr]
        var manager = AFHTTPRequestOperationManager()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("signup success")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            println("signup failed")
            self.handleRequestError(op, error: error, comp: comp)
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
            println(FBSDKAccessToken.currentAccessToken().tokenString)
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
            println("fbSignin user failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func fbUploadProfileImage(comp: completion) {
        let fbUserID = FBSDKAccessToken.currentAccessToken().userID
        let url = "http://graph.facebook.com/\(fbUserID)/picture?type=large"

        imageManager.getImageAtURL(url) { (image, error) -> () in
            if image != nil {
                println("fbUploadProfileImage \(url)")
                self.upLoadImage(image!, comp: comp)
            } else {
                println("fbUploadProfileImage failed")
                comp(true, "") // do not disturb the process
            }
        }
    }

    func upLoadImage(image: UIImage, comp: completion) {
        
        var urlStr = baseURL + "/api/me/upload"
        var url = NSURL(string: urlStr)!
        var imageData = UIImageJPEGRepresentation(image, 1.0)
        var token = userManager.userToken
        
        var request = NSMutableURLRequest(URL: url)
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("token " + token, forHTTPHeaderField: "Authorization")
        request.HTTPMethod = "POST"
        request.HTTPBody = imageData

        var op = AFHTTPRequestOperation(request: request)
        op.responseSerializer = AFJSONResponseSerializer()
        op.setCompletionBlockWithSuccess({ (op, obj) in
            println("succeess to upload image")
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
        var url = baseURL + "/api/me"
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
        var map = ["user": arr]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("update user success")
            self.userManager.setWithJsonReponse(JSON(obj))
            onMainThread() { self.postNotification("SignupFinished") }
            comp(true, "")
        }) { (op, error) in
            println("update user failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updatePhoneNumber(phone: String, comp: completion) {
        var url = baseURL + "/api/me"
        var map = ["user": ["phone_number": phone]]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("update phone success")
            self.userManager.setWithJsonReponse(JSON(obj))
            comp(true, "")
        }) { (op, error) in
            println("update phone failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateUserRole(role: String, comp: completion) {
        var url = baseURL + "/api/me"
        var arr = [
            "role": role.lowercaseString
        ]
        var map = ["user": arr]
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateUserRole success")
            self.userManager.setWithJsonReponse(JSON(obj))
            comp(true, "")
        }) { (op, error) in
            println("updateUserRole failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func resetPassword(email: String, comp: completion) {
        let url = "\(baseURL)/users/password"
        let manager = managerWithToken()
        manager.POST(url, parameters: ["email": email], success: { (op, obj) in
            println("resetPassword success")
            comp(true, "")
        }) { (op, error) in
            println("resetPassword failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
