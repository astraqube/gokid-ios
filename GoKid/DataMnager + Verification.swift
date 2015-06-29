//
//  DataMnager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/25/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

extension DataManager {
    
    func requestVerificationCode(phoneNum: String, comp: completion) {
        var url = baseURL + "/api/me/challenge"
        var map = [
            "challenge" : [
                "phone_number": phoneNum
            ]
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("requestingVerificationCode success")
            println(obj)
            comp(true, "")
        }) { (op, error) in
            println("requestingVerificationCode failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func VerifyCode(code: String, comp: completion) {
        var url = baseURL + "/api/me/verify"
        var map = [
            "verification": [
                "code": code
            ]
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("VerifyCode success")
            println(obj)
            comp(true, "")
        }) { (op, error) in
            println("VerifyCode failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
