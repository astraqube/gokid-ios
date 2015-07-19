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
        var map = [
            "carpool": [
                "name": model.name,
                "schedule": model.toSchedule()
            ]
        ]
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var json = JSON(obj)["carpool"]
            var carpool = CarpoolModel(json: json)
            self.userManager.currentCarpoolModel.id = carpool.id
            println("create carpool success")
            comp(true, "")
        }) { (op, error) in
            println("create carpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getAllUserOccurrences(comp: completion) {
        var url = baseURL + "/api/occurrences"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getAllUserOccurrences success")
            println(obj)
            var json = JSON(obj)["occurrences"]
            var events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            self.userManager.calendarEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getAllUserOccurrences failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getCarpools(comp: completion) {
        var url = baseURL + "/api/carpools"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getCarpool success")
            println(obj)
            var json = JSON(obj)["carpools"]
            var carpools = CarpoolModel.arrayOfCarpoolsFromJSON(json)
            self.userManager.carpools = carpools
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
            var events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            self.userManager.volunteerEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getOccurenceOfCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateOccurencesLocation(occs: [(OccurenceModel, OccurenceModel)], comp: completion) {
        var url = baseURL + "/carpools/" + String(userManager.currentCarpoolModel.id) + "/occurrences"
        
        var data = [OccurenceModel]()
        for (pickup, dropoff) in occs {
            data.append(pickup)
            data.append(dropoff)
        }
        
        var map = NSMutableArray()
        for occ in data {
            var json = [
                "occurrence_ids": [occ.occurenceID],
                "occurrence": [
                    "event_location": occ.eventLocation.toJson(),
                    "default_address": occ.defaultLocation.toJson()
                ]
            ]
            map.addObject(json)
        }
        
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
    
    func updateOccurenceRiders(occ: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/carpools/" + String(occ.carpoolID) + "/occurrences/" + String(occ.occurenceID) + "/riders"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("updateOccurenceRiders success")
            println(obj)
            var ridersJson = JSON(obj)["riders"]
            var riders = RiderModel.arrayOfRidersWithJSON(ridersJson)
            occ.riders = riders
            comp(true, "")
            }) { (op, error) in
                println("updateOccurenceRiders failed")
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
