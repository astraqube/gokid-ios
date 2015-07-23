//
//  DataManager + Notification.swift
//  
//
//  Created by Bingwen Fu on 6/27/15.
//
//

import UIKit

extension DataManager {
    func notifyRiderStopArrival(occurrence: OccurenceModel, rider: RiderModel, comp: completion) {
        var url = baseURL + "/api/occurrences/" + String(occurrence.occurenceID) + "/riders/" +  String(rider.riderID) + "/notifications"
        var map = ["notification": ["kind": "arriving"]]
        var manager = managerWithToken()
        manager.POST(url, parameters: map, success: { (op, obj) in
            println("notifyRiderStopArrival success")
            comp(true, "")
            }) { (op, error) in
                println("notifyRiderStopArrival failed")
                self.handleRequestError(op, error: error, comp: comp)
        }
    }
    
    func updateNotificationToken(token: String, comp: completion) {
        var url = baseURL + "/api_ios_device_token"
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
