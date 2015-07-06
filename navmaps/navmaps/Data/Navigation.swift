//
//  Navigation.swift
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

 :param: error an error called if Navigation can not update the ETA. After an error there will be no subsequent invocation of this callback.
 :param: minutes minutes until destination reached
*/
typealias ETACallback = ((error: NSError, minutes: Double) -> (Void))

/**
A callback to be called on in "navigation mode" with each periodic DirectionUpdate. Call `startUpdatingDirectionsWithCallback` first.

:param: error an error called if Navigation can not update the next direction. After an error there will be no subsequent invocation of this callback.
:param: nextDirection a localized String with the next direction the user should take
*/
typealias DirectionCallback = ((error: NSError, nextDirection : NSString))

/**
A callback to be called on each periodic LocationUpdate. Call `startUpdatingLocationWithCallback` first.

:param: error an error called if Navigation can not update the ETA. After an error there will be no subsequent invocation of this callback.
:param: location the current location of the user
*/
typealias LocationCallback = ((error: NSError, location : CLLocation))

/// The 🚏 data type used by Navigation. hasStopped is used internally to determine whether the stop, *a pickup or a dropoff*, has occured– `hasStopped` is therefore false by default.
class Stop : NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var name : String
    var thumbnailImage : UIImage?
    var hasStopped : Bool = false
    
    init(coordinate: CLLocationCoordinate2D, name: String, thumbnailImage: UIImage?) {
        self.coordinate = coordinate
        self.name = name
        self.thumbnailImage = thumbnailImage
    }
}

class Navigation : NSObject, CLLocationManagerDelegate {
    var onETAUpdate : ETACallback?
    var onDirectionUpdate : DirectionCallback?
    var onLocationUpdate : LocationCallback?

    var pickup : Stop!
    var dropoff : Stop!
    
    var locationManager : CLLocationManager!
    var pickupToDropoffResponse : MKDirectionsResponse!
    var currentToPickupResponse : MKDirectionsResponse!
    
    lazy var pickupToDropoffDirections : MKDirections = {
        var request = MKDirectionsRequest()
        request.setSource(MKMapItem(placemark: MKPlacemark(coordinate: self.pickup.coordinate, addressDictionary: nil)))
        request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: self.dropoff.coordinate, addressDictionary: nil)))
        return MKDirections(request: request)
    }()
    
    lazy var currentToPickupDirections : MKDirections = {
        var request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: self.dropoff.coordinate, addressDictionary: nil)))
        return MKDirections(request: request)
    }()
    
    init(pickup : Stop, dropoff : Stop) {
        super.init()
        self.pickup = pickup
        self.dropoff = dropoff
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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
    
    func calculatePickupToDropoffRouteWithCallback(callback: MKDirectionsHandler!) {
        if pickupToDropoffResponse != nil {
            return callback(pickupToDropoffResponse, nil)
        }
        pickupToDropoffDirections.calculateDirectionsWithCompletionHandler(callback)
    }

    func calculateCurrentToPickupRouteWithCallback(callback: MKDirectionsHandler!) {
        if currentToPickupResponse != nil {
            return callback(currentToPickupResponse, nil)
        }
        currentToPickupDirections.calculateDirectionsWithCompletionHandler(callback)
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status.rawValue < CLAuthorizationStatus.AuthorizedAlways.rawValue {
            return
        }
        calculateCurrentToPickupRouteWithCallback { (response: MKDirectionsResponse!, error: NSError!) -> Void in
            self.currentToPickupResponse = response
        }
    }
}
