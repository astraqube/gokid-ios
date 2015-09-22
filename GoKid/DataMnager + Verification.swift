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
        let url = baseURL + "/api/me/challenge"
        let map = [
            "challenge" : [
                "phone_number": phoneNum
            ]
        ]
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("requestingVerificationCode success", terminator: "")
            print(obj, terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("requestingVerificationCode failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func memberPhoneVerification(code: String, comp: completion) {
        let url = baseURL + "/api/me/verify"
        let map = [
            "verification": [
                "code": code
            ]
        ]
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("VerifyCode success", terminator: "")
            print(obj, terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("VerifyCode failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
