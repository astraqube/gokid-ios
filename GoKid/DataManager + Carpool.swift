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
                "schedule": model.toSchedule(),
                "kids": [[
                    "first_name": model.kidName,
                    "last_name": UserManager.sharedInstance.info.lastName
                ]]
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
            var json = JSON(obj)
            var ridersJ = json["riders"]
            var riders = RiderModel.arrayOfRidersWithJSON(ridersJ)
            RiderModel.cacheRiders(riders)
            var occurrencesJ = json["occurrences"]
            var events = OccurenceModel.arrayOfEventsFromOccurrences(occurrencesJ)
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
            var json = JSON(obj)
            var ridersJ = json["riders"]
            RiderModel.cacheRiders(RiderModel.arrayOfRidersWithJSON(ridersJ))
            var carpoolsJ = json["carpools"]
            var carpools = CarpoolModel.arrayOfCarpoolsFromJSON(carpoolsJ)
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
            var events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            self.userManager.volunteerEvents = events
            comp(true, "")
        }) { (op, error) in
            println("getOccurenceOfCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateOccurrenceLocation(occurrenceID: Int, location: Location, comp: completion) {
        var url = baseURL + "/api/occurrences/\(occurrenceID)"

        var map = [
            "occurrence": [
                "event_location": location.toJson()
            ]
        ]

        println(url)
        println(map)

        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateOccurrenceLocation success")
            var json = JSON(obj)
            println(json)
            comp(true, "")
        }) { (op, error) in
            println("updateOccurrenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateOccurencesLocation(occs: [(OccurenceModel, OccurenceModel)], comp: completion) {
        var url = baseURL + "/api/carpools/" + String(userManager.currentCarpoolModel.id) + "/occurrences"
        
        var data = [OccurenceModel]()
        for (pickup, dropoff) in occs {
            data.append(pickup)
            data.append(dropoff)
        }
        
        let map = [
            "occurrence_ids": data.map { return $0.occurenceID },
            "occurrence": [
                "event_location": data[0].eventLocation.toJson(),
                "default_address": data[0].defaultLocation.toJson()
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
    
    func putOccurrenceCurrentLocation(location: CLLocation, occurrence: OccurenceModel, comp: completion){
        var url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/location"
        let map = ["location" : [ "latitude" : location.coordinate.latitude,
            "longitude" : location.coordinate.longitude,
            "heading" : location.course
        ]]
        println(url)
        var manager = managerWithToken()
        manager.requestSerializer.timeoutInterval = 10 //the same as the request interval– don't want these piling up
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("putOccurrenceCurrentLocation success")
            comp(true, "")
            }) { (op, error) in
                println("putOccurrenceCurrentLocation failed")
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

    func updateRiderInCarpool(rider: RiderModel, carpoolID: Int, comp: ObjectCompletion) {
        var url = "\(baseURL)/api/carpools/\(carpoolID)/riders/\(rider.riderID)"
        var map = ["rider": rider.toJson()]

        println(url)
        println(map)

        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            println("updateRiderInCarpool success")
            println(obj)
            var json = JSON(obj)
            var rider = RiderModel(json: json["rider"])
            comp(true, "", rider)
        }) { (op, error) in
            println("updateRiderInCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func deleteFromOccurenceRiders(rider: RiderModel , occ: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/carpools/" + String(occ.carpoolID) + "/occurrences/" + String(occ.occurenceID) + "/riders/" + String(rider.riderID)
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("deleteFromOccurenceRiders success")
            println(obj)
            occ.riders.removeAtIndex(find(occ.riders, rider)!)
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
                "first_name": name,
                "last_name": self.userManager.info.lastName
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
