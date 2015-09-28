//
//  DataManager + Carpool.swift
//  
//
//  Created by Bingwen Fu on 6/23/15.
//
//

import UIKit

extension DataManager {
    func getCarpool(id: Int, comp: ObjectCompletion) {
        var url = baseURL + "/api/carpools/" + String(id)
        
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            var json = JSON(obj)
            var carpool = CarpoolModel(json: json["carpool"])
            
            println("get carpool success")
            
            comp(true, "", carpool)
        }) { (op, error) in
            println("get carpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }
    
    func createCarpool(model: CarpoolModel, comp: ObjectCompletion) {
        var url = baseURL + "/api/carpools"
        var map = model.toJson()
        println(map)
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var json = JSON(obj)
            model.reflect(json["carpool"])
            model.riders = RiderModel.arrayOfRidersWithJSON(json["riders"])
            println("create carpool success")
            comp(true, "", model)
        }) { (op, error) in
            println("create carpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func updateCarpool(model: CarpoolModel, comp: ObjectCompletion) {
        var url = baseURL + "/api/carpools/\(model.id)"
        var map = model.toJson()
        println(map)
        var manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            var json = JSON(obj)
            model.reflect(json["carpool"])
            println("updateCarpool success")
            comp(true, "", model)
        }) { (op, error) in
            println("updateCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func deleteOccurrence(model: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/carpools/\(model.carpoolID)/occurrences/\(model.occurenceID)"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("deleteOccurrence success")
            comp(true, "")
        }) { (op, error) in
            println("deleteOccurrence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func deleteCarpool(model: CarpoolModel, comp: completion) {
        var url = baseURL + "/api/carpools/\(model.id)"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("deleteCarpool success")
            comp(true, "")
        }) { (op, error) in
            println("deleteCarpool failed")
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

    func registerForCarpool(carpool: CarpoolModel, type: String, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpool.id)/claim"
        var manager = managerWithToken()
        manager.POST(url, parameters: ["occurrences": type], success: { (op, obj) in
            println("registerForCarpool success")
            comp(true, "")
        }) { (op, error) in
            println("registerForCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func unregisterForCarpool(carpool: CarpoolModel, type: String, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpool.id)/claim"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: ["occurrences": type], success: { (op, obj) in
            println("registerForCarpool success")
            comp(true, "")
        }) { (op, error) in
            println("registerForCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func registerForOccurence(occ: OccurenceModel, comp: completion) {
        registerForOccurence(occ, member: nil, comp: comp)
    }

    func registerForOccurence(occ: OccurenceModel, member: TeamMemberModel?, comp: completion) {
        var url = baseURL + "/api/carpools/\(occ.carpool.id)/occurrences/\(occ.occurenceID)/claim"
        var map: NSDictionary!

        if member != nil {
            map = ["user_id": member!.userID]
        }

        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("registerForOccurence success")
            println(obj)
            var json = JSON(obj)
            occ.reflect(json["occurrence"])
            comp(true, "")
        }) { (op, error) in
            println("registerForOccurence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func unregisterForOccurence(occ: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/carpools/\(occ.carpool.id)/occurrences/\(occ.occurenceID)/claim"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("registerForOccurence success")
            println(obj)
            var json = JSON(obj)
            occ.reflect(json["occurrence"])
            comp(true, "")
        }) { (op, error) in
            println("registerForOccurence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func getOccurenceOfCarpool(carpoolID: Int, comp: completion) {
        getOccurenceOfCarpool(carpoolID, rider: nil, comp: comp)
    }

    func getOccurenceOfCarpool(carpoolID: Int, rider: RiderModel?, comp: completion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences"

        if rider != nil {
            url = url + "?only_rider=\(rider!.riderID)"
        }

        println(url)
        var manager = managerWithToken()
        println(userManager.userToken)
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Pragma")
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getOccurenceOfCarpool success")
            var json = JSON(obj)["occurrences"]
            self.userManager.volunteerEvents = OccurenceModel.arrayOfEventsFromOccurrences(json)
            comp(true, "")
        }) { (op, error) in
            println("getOccurenceOfCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getOccurenceOfCarpool2(carpoolID: Int, comp: ObjectCompletion) {
        getOccurenceOfCarpool2(carpoolID, rider: nil, comp: comp)
    }
    
    func getOccurenceOfCarpool2(carpoolID: Int, rider: RiderModel?, comp: ObjectCompletion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/occurrences"
        
        if rider != nil {
            url = url + "?only_rider=\(rider!.riderID)"
        }
        
        println(url)
        var manager = managerWithToken()
        println(userManager.userToken)
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Pragma")
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getOccurenceOfCarpool success")
            var json = JSON(obj)["occurrences"]
            var events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            comp(true, "", events)
        }) { (op, error) in
            println("getOccurenceOfCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func updateOccurrencesInBulk(occurrences: [OccurenceModel], comp: ObjectCompletion) {
        let url = baseURL + "/api/occurrences"
        var map = NSDictionary() as! [Int : NSDictionary]

        for occ in occurrences {
            map[occ.occurenceID] = [
                "event_location": occ.eventLocation.toJson(),
                "default_address": occ.defaultLocation.toJson()
            ]
        }

        println(url)
        println(map)

        var manager = managerWithToken()
        manager.PUT(url, parameters: ["occurrences": map], success: { (op, obj) in
            println("updateOccurrencesInBulk success")
            let json = JSON(obj)
            println(json)
            let occurrences = OccurenceModel.arrayOfEventsFromOccurrences(json["bulk_occurrences"])
            comp(true, "", occurrences)
        }) { (op, error) in
            println("updateOccurrencesInBulk failed")
            self.handleUserResuestError(op, error: error, comp: comp)
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
            comp(true, "")
        }) { (op, error) in
            println("updateOccurrenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateOccurencesLocation(occs: [OccurenceModel], comp: completion) {
        var url = baseURL + "/api/carpools/" + String(userManager.currentCarpoolModel.id) + "/occurrences"
        
        let map = [
            "occurrence_ids": occs.map { return $0.occurenceID },
            "occurrence": [
                "event_location": occs[0].eventLocation.toJson(),
                "default_address": occs[0].defaultLocation.toJson()
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
    
    func updateOccurencesTimes(occs: [OccurenceModel], comp: completion) {
        var url = baseURL + "/api/occurrences"
        
        var map = NSMutableDictionary.new()
        
        for o in occs {
            var id = String(o.occurenceID)
            var updates = ["occursAt": o.occursAt!.iso8601String()]
            map[id] = updates
        }
        
        var payload = ["occurrences": map]
        
        println(url)
        println(payload)
        
        var manager = managerWithToken()
        manager.PUT(url, parameters: payload, success: { (op, obj) in
            println("updateOccurencesTimes success")
            comp(true, "")
        }) { (op, error) in
            println(error)
            println("updateOccurenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateOccurencesTimes2(updates: NSMutableDictionary, comp: completion) {
        var url = baseURL + "/api/occurrences"
        
        var payload = ["occurrences": updates]
        
        println(url)
        println(payload)
        
        var manager = managerWithToken()
        manager.PUT(url, parameters: payload, success: { (op, obj) in
            println("updateOccurencesTimes success")
            comp(true, "")
        }) { (op, error) in
            println(error)
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
    
    func getOccurenceRiders(occ: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/carpools/" + String(occ.carpoolID) + "/occurrences/" + String(occ.occurenceID) + "/riders"
        var manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getOccurenceRiders success")
            println(obj)
            var ridersJson = JSON(obj)["riders"]
            var riders = RiderModel.arrayOfRidersWithJSON(ridersJson)
            occ.riders = riders
            comp(true, "")
        }) { (op, error) in
            println("getOccurenceRiders failed")
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
        var url = baseURL + "/api/occurrences/\(occ.occurenceID)/riders/\(rider.riderID)"
        var manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            println("deleteFromOccurenceRiders success")
            comp(true, "")
        }) { (op, error) in
            println("deleteFromOccurenceRiders failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func addRiderToOccurrence(rider: RiderModel, occ: OccurenceModel, comp: completion) {
        var url = baseURL + "/api/occurrences/\(occ.occurenceID)/riders/\(rider.riderID)"
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("addRiderToOccurrence success")
            comp(true, "")
        }) { (op, error) in
            println("addRiderToOccurrence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func addKidsNameToCarpool(carpoolID: Int, name: String, comp: ObjectCompletion) {
        var url = baseURL + "/api/carpools/\(carpoolID)/riders"
        var map = [
            "rider" : [
                "first_name": name,
                "last_name": self.userManager.info.lastName
            ]
        ]
        var manager = managerWithToken()
        manager.POST(url, parameters:map, success: { (op, obj) in
            println("addKidsNameToCarpool success")
            let json = JSON(obj)
            let rider = RiderModel(json: json["rider"])
            comp(true, "", rider)
        }) { (op, error) in
            println("addKidsNameToCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func getCarpoolInvites(carpool: CarpoolModel, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools/\(carpool.id)/invites"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            println("getCarpoolInvites success")
            let json = JSON(obj)
            let invitations = json["invites"].arrayValue
            let invites = invitations.map {
                return InvitationModel(json: $0)
            }
            comp(true, "", invites)
        }) { (op, error) in
            println("getCarpoolInvites failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

}
