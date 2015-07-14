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
            "starts_at": model.startDate!.iso8601String(),
            "ends_at": model.endDate!.iso8601String(),
            "days_occuring": model.occurence!,
            "time_zone": "Pacific Time (US & Canada)",
        ]
        var map = [
            "carpool": [
                "name": model.name,
                "schedule": schedule
            ]
        ]
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpoolModel.id = carpool.id
            println("create carpool success")
            comp(true, "")
        }) { (op, error) in
            println("create carpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getAllUserCarpools(comp: completion) {
        var url = baseURL + "/api/occurrences"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getAllUserCarpools success")
            println(obj)
            var json = JSON(obj)["occurrences"]
            var events = CalendarModel.arrayOfEventsFromOccurrences(json)
            self.userManager.calendarEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getAllUserCarpools failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getCarpools(comp: completion) {
        var url = baseURL + "/api/carpools"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getCarpool success")
            println(obj)
            var carpool = CarpoolModel(json: JSON(obj))
            self.userManager.currentCarpoolModel = carpool
            comp(true, "")
        }) { (op, error) in
            println("get carpool failed")
            self.handleRequestError(op, error: error, comp: comp)
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
            self.handleRequestError(op, error: error, comp: comp)
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
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getOccurenceOfCarpool(carpoolID: Int, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences"
        println(url)
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getOccurenceOfCarpool success")
            var json = JSON(obj)["occurrences"]
            println(json)
            var events = CalendarModel.arrayOfEventsFromOccurrences(json)
            self.userManager.volunteerEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getOccurenceOfCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    
    func updateOccurenceLocation(occ: CalendarModel, comp: completion) {
        var url = baseURL + "/api/occurrences/" + String(occ.occurenceID)
        var map = [
            "occurrence": [
                "locations": [
                    "display": occ.poolLocation.name,
                    "longitude": occ.poolLocation.long,
                    "latitude": occ.poolLocation.lati
                ]
            ]
        ]
        println(url)
        println(map)
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateOccurenceLocation success")
            var json = JSON(obj)
            println(json)
            comp(true, "")
        }) { (op, error) in
            println("updateOccurenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func addKidsNameToCarpool(carpoolID: Int, name: String, comp: completion) {
        var url = baseURL + "/api/carpools/" + String(carpoolID) + "/riders"
        var map = [
            "rider" : [
                "first_name": name
            ]
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters:map, success: { (op, obj) in
            println("addKidsNameToCarpool success")
            comp(true, "")
        }) { (op, error) in
            println("addKidsNameToCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
