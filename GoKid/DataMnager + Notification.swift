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
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("notifyRider \(rider.riderID) \(kind) success", terminator: "")
            comp(true, "")
            }) { (op, error) in
                print("notifyRider \(rider.riderID) \(kind) failed", terminator: "")
                self.handleRequestError(op, error: error, comp: comp)
        }
    }

    func notifyRiders(type:RiderNotificationType, occurrence: OccurenceModel, comp: completion) {
        let url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/notifications"
        let kind = getNotificationKind(type)
        let map = ["notification": ["kind": kind]]
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("notifyRiders \(occurrence.occurenceID) \(kind) success", terminator: "")
            comp(true, "")
            }) { (op, error) in
                print("notifyRiders \(occurrence.occurenceID) \(kind) failed", terminator: "")
                self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateNotificationToken(token: String, comp: completion) {
        let url = baseURL + "/api/ios_device_token"
        let map = ["device_token": token]
        let manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            print("updateNotificationToken success", terminator: "")
            print(obj, terminator: "")
            comp(true, "")
        }) { (op, error) in
            print("updateNotificationToken failed", terminator: "")
            self.handleRequestError(op, error: error, comp: comp)
        }
    }
}
