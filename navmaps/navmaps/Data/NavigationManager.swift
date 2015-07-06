//
//  NavigationManager.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/5/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/**
 A callback to be called on each periodic ETAUpdate. Call `startUpdatingETAWithCallback` first.

 :param: error an error called if NavigationManager can not update the ETA. After an error there will be no subsequent invocation of this callback.
 :param: minutes minutes until destination reached
*/
typealias ETACallback = ((error: NSError, minutes: Double) -> (Void))

/**
A callback to be called on in "navigation mode" with each periodic DirectionUpdate. Call `startUpdatingDirectionsWithCallback` first.

:param: error an error called if NavigationManager can not update the next direction. After an error there will be no subsequent invocation of this callback.
:param: nextDirection a localized String with the next direction the user should take
*/
typealias DirectionCallback = ((error: NSError, nextDirection : NSString))

/**
A callback to be called on each periodic LocationUpdate. Call `startUpdatingLocationWithCallback` first.

:param: error an error called if the Manager can not update the ETA. After an error there will be no subsequent invocation of this callback.
:param: location the current location of the user
*/
typealias LocationCallback = ((error: NSError, location : CLLocation))

/**
 The dataType used by NavigationManager. hasStopped is used internally to determine whether the stop, *a pickup or a dropoff*, has occured– `hasStopped` is therefore false by default.
*/
struct Stop {
    var coordinate : CLLocationCoordinate2D
    var name : String
    var thumbnailImage : UIImage
    var hasStopped : Bool = false
    
    init(coordinate: CLLocationCoordinate2D, name: String, thumbnailImage: UIImage) {
        self.coordinate = coordinate
        self.name = name
        self.thumbnailImage = thumbnailImage
    }
}

class NavigationManager: NSObject {
    var onETAUpdate : ETACallback?
    var onDirectionUpdate : DirectionCallback?
    var onLocationUpdate : LocationCallback?

    var pickup : Stop!
    var dropoff : Stop!
    
    init(pickup : Stop, dropoff : Stop) {
        self.pickup = pickup
        self.dropoff = dropoff
    }
    
    func startUpdatingETAWithCallback(callback : ETACallback) {
        onETAUpdate = callback
    }
    
    func startUpdatingDirectionsWithCallback(callback : DirectionCallback) {
        onDirectionUpdate = callback
    }

    func startUpdatingLocationWithCallback(callback : LocationCallback) {
        onLocationUpdate = callback
        
    }
}
