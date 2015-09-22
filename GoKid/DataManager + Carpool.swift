//
//  DataManager + Carpool.swift
//  
//
//  Created by Bingwen Fu on 6/23/15.
//
//

import UIKit
import SwiftyJSON

extension DataManager {
    func getCarpool(id: Int, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools/" + String(id)
        
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            var json = JSON(obj)
            let carpool = CarpoolModel(json: json["carpool"])
            
            print("get carpool success")
            
            comp(true, "", carpool)
        }) { (op, error) in
            print("get carpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }
    
    func createCarpool(model: CarpoolModel, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools"
        let map = model.toJson()
        print(map)
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            var json = JSON(obj)
            model.reflect(json["carpool"])
            model.riders = RiderModel.arrayOfRidersWithJSON(json["riders"])
            print("create carpool success")
            comp(true, "", model)
        }) { (op, error) in
            print("create carpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func updateCarpool(model: CarpoolModel, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools/\(model.id)"
        let map = model.toJson()
        print(map)
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            var json = JSON(obj)
            model.reflect(json["carpool"])
            print("updateCarpool success")
            comp(true, "", model)
        }) { (op, error) in
            print("updateCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func deleteOccurrence(model: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/carpools/\(model.carpoolID)/occurrences/\(model.occurenceID)"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            print("deleteOccurrence success")
            comp(true, "")
        }) { (op, error) in
            print("deleteOccurrence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func deleteCarpool(model: CarpoolModel, comp: completion) {
        let url = baseURL + "/api/carpools/\(model.id)"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            print("deleteCarpool success")
            comp(true, "")
        }) { (op, error) in
            print("deleteCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func getAllUserOccurrences(comp: completion) {
        let url = baseURL + "/api/occurrences"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getAllUserOccurrences success")
            var json = JSON(obj)
            let ridersJ = json["riders"]
            let riders = RiderModel.arrayOfRidersWithJSON(ridersJ)
            RiderModel.cacheRiders(riders)
            let occurrencesJ = json["occurrences"]
            let events = OccurenceModel.arrayOfEventsFromOccurrences(occurrencesJ)
            self.userManager.calendarEvents = events
            comp(true, "")
        }) { (op, error) in
            print("getAllUserOccurrences failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getCarpools(comp: completion) {
        let url = baseURL + "/api/carpools"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getCarpool success")
            print(obj)
            var json = JSON(obj)
            let ridersJ = json["riders"]
            RiderModel.cacheRiders(RiderModel.arrayOfRidersWithJSON(ridersJ))
            let carpoolsJ = json["carpools"]
            let carpools = CarpoolModel.arrayOfCarpoolsFromJSON(carpoolsJ)
            self.userManager.carpools = carpools
            comp(true, "")
        }) { (op, error) in
            print("get carpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func registerForCarpool(carpool: CarpoolModel, type: String, comp: completion) {
        let url = baseURL + "/api/carpools/\(carpool.id)/claim"
        let manager = managerWithToken()
        manager.POST(url, parameters: ["occurrences": type], success: { (op, obj) in
            print("registerForCarpool success")
            comp(true, "")
        }) { (op, error) in
            print("registerForCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func unregisterForCarpool(carpool: CarpoolModel, type: String, comp: completion) {
        let url = baseURL + "/api/carpools/\(carpool.id)/claim"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: ["occurrences": type], success: { (op, obj) in
            print("registerForCarpool success")
            comp(true, "")
        }) { (op, error) in
            print("registerForCarpool failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func registerForOccurence(occ: OccurenceModel, comp: completion) {
        registerForOccurence(occ, member: nil, comp: comp)
    }

    func registerForOccurence(occ: OccurenceModel, member: TeamMemberModel?, comp: completion) {
        let url = baseURL + "/api/carpools/\(occ.carpool.id)/occurrences/\(occ.occurenceID)/claim"
        var map: NSDictionary!

        if member != nil {
            map = ["user_id": member!.userID]
        }

        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("registerForOccurence success")
            print(obj)
            var json = JSON(obj)
            occ.reflect(json["occurrence"])
            comp(true, "")
        }) { (op, error) in
            print("registerForOccurence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func unregisterForOccurence(occ: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/carpools/\(occ.carpool.id)/occurrences/\(occ.occurenceID)/claim"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            print("registerForOccurence success")
            print(obj)
            var json = JSON(obj)
            occ.reflect(json["occurrence"])
            comp(true, "")
        }) { (op, error) in
            print("registerForOccurence failed")
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

        print(url)
        let manager = managerWithToken()
        print(userManager.userToken)
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Pragma")
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getOccurenceOfCarpool success")
            let json = JSON(obj)["occurrences"]
            let events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            self.userManager.volunteerEvents = events.sort() { (left : OccurenceModel, right : OccurenceModel) -> Bool in
                if left.occursAt == nil || right.occursAt == nil { return false}
                return left.occursAt!.isLessThanDate(right.occursAt!)
            }
            comp(true, "")
        }) { (op, error) in
            print("getOccurenceOfCarpool failed")
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
        
        print(url)
        let manager = managerWithToken()
        print(userManager.userToken)
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Pragma")
        manager.requestSerializer.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getOccurenceOfCarpool success")
            let json = JSON(obj)["occurrences"]
            let events = OccurenceModel.arrayOfEventsFromOccurrences(json)
            comp(true, "", events)
        }) { (op, error) in
            print("getOccurenceOfCarpool failed")
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

        print(url)
        print(map)

        let manager = managerWithToken()
        manager.PUT(url, parameters: ["occurrences": map], success: { (op, obj) in
            print("updateOccurrencesInBulk success")
            let json = JSON(obj)
            print(json)
            let occurrences = OccurenceModel.arrayOfEventsFromOccurrences(json["bulk_occurrences"])
            comp(true, "", occurrences)
        }) { (op, error) in
            print("updateOccurrencesInBulk failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func updateOccurrenceLocation(occurrenceID: Int, location: Location, comp: completion) {
        let url = baseURL + "/api/occurrences/\(occurrenceID)"

        let map = [
            "occurrence": [
                "event_location": location.toJson()
            ]
        ]

        print(url)
        print(map)

        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateOccurrenceLocation success")
            comp(true, "")
        }) { (op, error) in
            print("updateOccurrenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateOccurencesLocation(occs: [OccurenceModel], comp: completion) {
        let url = baseURL + "/api/carpools/" + String(userManager.currentCarpoolModel.id) + "/occurrences"
        
        let map = [
            "occurrence_ids": occs.map { return $0.occurenceID },
            "occurrence": [
                "event_location": occs[0].eventLocation.toJson(),
                "default_address": occs[0].defaultLocation.toJson()
            ]
        ]
        
        print(url)
        print(map)
        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateOccurenceLocation success")
            let json = JSON(obj)
            print(json)
            comp(true, "")
        }) { (op, error) in
            print("updateOccurenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateOccurencesTimes(occs: [OccurenceModel], comp: completion) {
        let url = baseURL + "/api/occurrences"
        
        let map = NSMutableDictionary()
        
        for o in occs {
            let id = String(o.occurenceID)
            let updates = ["occursAt": o.occursAt!.iso8601String()]
            map[id] = updates
        }
        
        let payload = ["occurrences": map]
        
        print(url)
        print(payload)
        
        let manager = managerWithToken()
        manager.PUT(url, parameters: payload, success: { (op, obj) in
            print("updateOccurencesTimes success")
            comp(true, "")
        }) { (op, error) in
            print(error)
            print("updateOccurenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateOccurencesTimes2(updates: NSMutableDictionary, comp: completion) {
        let url = baseURL + "/api/occurrences"
        
        let payload = ["occurrences": updates]
        
        print(url)
        print(payload)
        
        let manager = managerWithToken()
        manager.PUT(url, parameters: payload, success: { (op, obj) in
            print("updateOccurencesTimes success")
            comp(true, "")
        }) { (op, error) in
            print(error)
            print("updateOccurenceLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    
    func putOccurrenceCurrentLocation(location: CLLocation, occurrence: OccurenceModel, comp: completion){
        let url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/location"
        let map = ["location" : [ "latitude" : location.coordinate.latitude,
            "longitude" : location.coordinate.longitude,
            "heading" : location.course
        ]]
        print(url)
        let manager = managerWithToken()
        manager.requestSerializer.timeoutInterval = 10 //the same as the request interval– don't want these piling up
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("putOccurrenceCurrentLocation success")
            comp(true, "")
        }) { (op, error) in
            print("putOccurrenceCurrentLocation failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func getOccurenceRiders(occ: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/carpools/" + String(occ.carpoolID) + "/occurrences/" + String(occ.occurenceID) + "/riders"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getOccurenceRiders success")
            print(obj)
            let ridersJson = JSON(obj)["riders"]
            let riders = RiderModel.arrayOfRidersWithJSON(ridersJson)
            occ.riders = riders
            comp(true, "")
        }) { (op, error) in
            print("getOccurenceRiders failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func updateRiderInCarpool(rider: RiderModel, carpoolID: Int, comp: ObjectCompletion) {
        let url = "\(baseURL)/api/carpools/\(carpoolID)/riders/\(rider.riderID)"
        let map = ["rider": rider.toJson()]

        print(url)
        print(map)

        let manager = managerWithToken()
        manager.PUT(url, parameters: map, success: { (op, obj) in
            print("updateRiderInCarpool success")
            print(obj)
            var json = JSON(obj)
            let rider = RiderModel(json: json["rider"])
            comp(true, "", rider)
        }) { (op, error) in
            print("updateRiderInCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func deleteFromOccurenceRiders(rider: RiderModel , occ: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/occurrences/\(occ.occurenceID)/riders/\(rider.riderID)"
        let manager = managerWithToken()
        manager.DELETE(url, parameters: nil, success: { (op, obj) in
            print("deleteFromOccurenceRiders success")
            comp(true, "")
        }) { (op, error) in
            print("deleteFromOccurenceRiders failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func addRiderToOccurrence(rider: RiderModel, occ: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/occurrences/\(occ.occurenceID)/riders/\(rider.riderID)"
        let manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            print("addRiderToOccurrence success")
            comp(true, "")
        }) { (op, error) in
            print("addRiderToOccurrence failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func addKidsNameToCarpool(carpoolID: Int, name: String, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools/\(carpoolID)/riders"
        let map = [
            "rider" : [
                "first_name": name,
                "last_name": self.userManager.info.lastName
            ]
        ]
        let manager = managerWithToken()
        manager.POST(url, parameters:map, success: { (op, obj) in
            print("addKidsNameToCarpool success")
            let json = JSON(obj)
            let rider = RiderModel(json: json["rider"])
            comp(true, "", rider)
        }) { (op, error) in
            print("addKidsNameToCarpool failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

    func getCarpoolInvites(carpool: CarpoolModel, comp: ObjectCompletion) {
        let url = baseURL + "/api/carpools/\(carpool.id)/invites"
        let manager = managerWithToken()
        manager.GET(url, parameters: nil, success: { (op, obj) in
            print("getCarpoolInvites success")
            let json = JSON(obj)
            let invitations = json["invites"].arrayValue
            let invites = invitations.map {
                return InvitationModel(json: $0)
            }
            comp(true, "", invites)
        }) { (op, error) in
            print("getCarpoolInvites failed")
            self.handleUserResuestError(op, error: error, comp: comp)
        }
    }

}
