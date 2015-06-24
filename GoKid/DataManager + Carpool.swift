//
//  DataManager + Carpool.swift
//  
//
//  Created by Bingwen Fu on 6/23/15.
//
//

import UIKit

extension DataManager {
    
    func createCarpool(model: CarpoolModel, date: NSDate, comp: completion) {
        var url = baseURL + "/api/carpools"
        var schedule = [
            "arrive_at": model.dropOffTime!.iso8601String(),
            "depart_at": model.pickUpTime!.iso8601String(),
            "starts_at": model.startDate!.iso8601String(),
            "ends_at": model.endDate!.iso8601String(),
            "days_occuring": model.occurence!
        ]
        var map = [
            "carpool": [
                "name": model.name,
                "schedule": schedule
            ]
        ]
        
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpoolModel = carpool
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
            self.userManager.currentCarpoolModel = carpool
            comp(true, "")
            }) { (op, error) in
                println("get carpool failed")
                var errorStr = self.constructErrorStr(op, error: error)
                println(errorStr)
                comp(false, errorStr)
        }
    }
}
