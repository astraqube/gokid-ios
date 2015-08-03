//
//  DataManager + Notification.swift
//  
//
//  Created by Bingwen Fu on 6/27/15.
//
//

import UIKit

enum RiderNotificationType {
    case Approaching
    case Arriving
    case Delayed
    case RideComplete
}

extension DataManager {
    func getNotificationKind(type:RiderNotificationType) -> String {
        switch type{
        case .Approaching:
            return "approaching"
        case .Arriving:
            return "arriving"
        case .Delayed:
            return "delayed"
        case .RideComplete:
            return "complete"
        }
    }
    
    func notifyRider(type:RiderNotificationType, occurrence: OccurenceModel, rider: RiderModel, comp: completion) {
        let url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/riders/" +  String(rider.riderID) + "/notifications"
        let kind = getNotificationKind(type)
        let map = ["notification": ["kind": kind]]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("notifyRider \(rider.riderID) \(kind) success")
            comp(true, "")
            }) { (op, error) in
                println("notifyRider \(rider.riderID) \(kind) failed")
                self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func notifyRiders(type:RiderNotificationType, occurrence: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/notifications"
        let kind = getNotificationKind(type)
        let map = ["notification": ["kind": kind]]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("notifyRiders \(occurrence.occurenceID) \(kind) success")
            comp(true, "")
            }) { (op, error) in
                println("notifyRiders \(occurrence.occurenceID) \(kind) failed")
                self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateNotificationToken(token: String, comp: completion) {
        var url = baseURL + "/api/ios_device_token"
        var map = ["device_token": token]
        var manager = managerWithToken()
        manager.POST(url, parameters: nil, success: { (op, obj) in
            println("updateNotificationToken success")
            println(obj)
            comp(true, "")
        }) { (op, error) in
            println("updateNotificationToken failed")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
