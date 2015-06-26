//
//  DataManager + Carpool.swift
//  
//
//  Created by Bingwen Fu on 6/23/15.
//
//

import UIKit

extension DataManager {
    
    func createCarpool(model: CarpoolModel, comp: completion) {
        var url = baseURL + "/api/carpools"
        var schedule = [
            "dropoff_at": model.dropOffTime!.iso8601String(),
            "pickup_at": model.pickUpTime!.iso8601String(),
            "date_starts_at": model.startDate!.iso8601String(),
            "date_ends_at": model.endDate!.iso8601String(),
            "days_occuring": model.occurence!
        ]
        var map = [
            "carpool": [
                "name": model.name,
                "schedule": schedule
            ]
        ]
        println("try create carpool")
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpoolModel.id = carpool.id
            println("create carpool success")
            println(obj)
            comp(true, "")
            }) { (op, error) in
                println("create carpool failed")
                var errorStr = self.constructErrorStr(op, error: error)
                comp(false, errorStr)
        }
    }
    
    func getAllUserCarpools(comp: completion) {
        var url = baseURL + "/api/occurrences"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getAllUserCarpools success")
            var json = JSON(obj)["occurrences"]
            println(json)
            var events = CalendarModel.arrayOfEventsFromOccurrences(json)
            self.userManager.calendarEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getAllUserCarpools failed")
            var errorStr = self.constructErrorStr(op, error: error)
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
            comp(false, errorStr)
        }
    }
    
    func registerForOccurence(carpoolID: Int, occurID: Int, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences/\(occurID)/claim"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("registerForOccurence success")
            println(obj)
            comp(true, "")
            }) { (op, error) in
                println("registerForOccurence failed")
                var errorStr = self.constructErrorStr(op, error: error)
                comp(false, errorStr)
        }
    }
    
    func unregisterForOccurence(carpoolID: Int, occurID: Int, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences/\(occurID)/claim"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("registerForOccurence success")
            println(obj)
            comp(true, "")
            }) { (op, error) in
                println("registerForOccurence failed")
                var errorStr = self.constructErrorStr(op, error: error)
                comp(false, errorStr)
        }
    }
    
    func occurenceOfCarpool(carpoolID: Int, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("occurenceOfCarpool success")
            var json = JSON(obj)["occurrences"]
            println(json)
            var events = CalendarModel.arrayOfEventsFromOccurrences(json)
            self.userManager.volunteerEvents = events
            comp(true, "")
        }) { (op, error) in
                println("occurenceOfCarpool failed")
                var errorStr = self.constructErrorStr(op, error: error)
                comp(false, errorStr)
        }
    }
}
