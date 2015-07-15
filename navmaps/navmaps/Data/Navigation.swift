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
 :param: error an error called if Navigation can not update the ETA. After an error there will be no subsequent invocation of this callback.
 :param: minutes minutes until destination reached
*/
typealias ETACallback = ((error: NSError, minutes: Double) -> (Void))

/**
:param: error an error called if Navigation can not update the next direction. After an error there will be no subsequent invocation of this callback.
:param: nextDirection a localized String with the next direction the user should take
*/
typealias DirectionCallback = ((error: NSError, nextDirection : NSString))

/**
:param: error an error called if Navigation can not update the ETA. After an error there will be no subsequent invocation of this callback.
:param: location the current location of the user
*/
typealias LocationCallback = ((error: NSError, location : CLLocation))

/// The 🚏 data type used by Navigation. hasStopped is used internally to determine whether the stop, *a pickup or a dropoff*, has occured– `hasStopped` is therefore false by default.
class Stop : NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var name : NSString
    var address : NSString?
    var thumbnailImage : UIImage?
    var phoneNumber : NSString
    var stopID : NSString
    var hasStopped : Bool = false
    
    init(coordinate: CLLocationCoordinate2D, name: NSString, address: NSString, phoneNumber : NSString, stopID : NSString, thumbnailImage: UIImage?) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.stopID = stopID
        self.thumbnailImage = thumbnailImage
    }
    
    init(occurrence: OccurenceModel) {
        self.coordinate = CLLocationCoordinate2DMake(occurrence.defaultLocation.lati, occurrence.defaultLocation.long)
        self.name = occurrence.poolname
        self.address = occurrence.defaultLocation.name
        self.stopID = occurrence.defaultLocation.stopID
        self.phoneNumber = occurrence.poolDriverPhoneNum
    }
}

/**
This class takes pickups and dropoffs, sorts them, then manages routing from stop to stop.
*/
class Navigation : NSObject, CLLocationManagerDelegate {
    ///A callback to be called on each periodic ETAUpdate. Call `startUpdatingETAWithCallback` first.
    var onETAUpdate : ETACallback?
    ///A callback to be called on in "navigation mode" with each periodic DirectionUpdate. Use `startUpdatingDirectionsWithCallback`.
    var onDirectionUpdate : DirectionCallback?
    ///A callback to be called on each periodic LocationUpdate. Use `startUpdatingLocationWithCallback`.
    var onLocationUpdate : LocationCallback?
    ///A callback to be called after locationToCurrentStopDirection completes. Use `calculateCurrentToPickupRouteWithCallback`.
    var onLocationToCurrentStopRouteDetermined : MKDirectionsHandler?
    var pickups : [Stop]! = [] {
        didSet { sortStops(&self.pickups!, beginningAt: self.pickups.first) }
    }
    var dropoffs : [Stop]! = []{
        didSet {
            if self.dropoffs.count == 0 { return }
            var lastStop = self.dropoffs.removeLast()
            sortStops(&self.dropoffs!, beginningAt: self.pickups.last)
            self.dropoffs.append(lastStop)
        }
    }

    func sortStops(inout stops: [Stop], beginningAt : Stop?) {
        let firstCoord = beginningAt?.coordinate
        let firstLocation = CLLocation(latitude: firstCoord!.latitude, longitude: firstCoord!.longitude)
        stops.sort({ (stopA, stopB) -> Bool in
            let distanceA = firstLocation.distanceFromLocation(CLLocation(latitude: stopA.coordinate.latitude, longitude: stopA.coordinate.longitude))
            let distanceB = firstLocation.distanceFromLocation(CLLocation(latitude: stopB.coordinate.latitude, longitude: stopB.coordinate.longitude))
            return distanceA < distanceB
        })
    }
    
    /// The next pickup where `pickup.hasStopped == false`, otherwise, the next dropoff where `dropoff.hasStopped == false`, otherwise nil.
    var currentStop : Stop? {
        get {
            for stop in pickups + dropoffs {
                if stop.hasStopped == false{
                    return stop
                }
            }
            return nil
        }
    }

    var locationManager : CLLocationManager!
    var pickupToDropoffResponse : MKDirectionsResponse?
    var locationToCurrentStopResponse : MKDirectionsResponse?

    /**
    Contains all the responses for each step of route, from first pickup to last dropoff.
    Count is `count(pickups + dropoffs) - 1`
    `calculatePickupToDropoffRoutePiecesWithUpdateCallback` initializes with all nils, then populates.
    */
    var stopStepResponses : [MKDirectionsResponse?]?
    
    lazy var pickupToDropoffDirections : MKDirections? = {
        return self.stopToStopDirections( self.pickups.first , second: self.dropoffs.first )
    }()
    
    /**
    :param: pickups a list of pickups to be made. After set, this list will be sorted by ascending distance from `pickups.first`
    :param: dropoffs a list of dropoffs to be made AFTER `pickups.hasStopped == true`. After set, this list will be sorted ascending distance from `pickups.last`, with `dropoffs.last` last.
    */
    func setup(pickups : [Stop], dropoffs : [Stop]) {
        self.pickups = pickups
        self.dropoffs = dropoffs
    }
    
    ///call this function when you've set a Stop hasStopped to true or false
    ///it will lead to updates causing your onDirectionUpdate to fire, etc
    func updateForStopped() {
        locationToCurrentStopResponse = nil
        locationToCurrentStopDirections = nil
        if onDirectionUpdate != nil {
            println("since on directionUpdate running, we should update this")
        }
    }
    
    //CALCULATIONS SECTION
    func stopToStopDirections(first: Stop? , second: Stop?) -> MKDirections? {
        if first == nil || second == nil {
            return nil
        }
        var request = MKDirectionsRequest()
        request.setSource(MKMapItem(placemark: MKPlacemark(coordinate: first!.coordinate, addressDictionary: nil)))
        request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: second!.coordinate, addressDictionary: nil)))
        return MKDirections(request: request)
    }
    

    var _locationToCurrentStopDirections : MKDirections?
    var locationToCurrentStopDirections : MKDirections? {
        get {
            if _locationToCurrentStopDirections == nil {
                if self.currentStop == nil { return nil }
                var request = MKDirectionsRequest()
                request.setSource(MKMapItem.mapItemForCurrentLocation())
                request.setDestination(MKMapItem(placemark: MKPlacemark(coordinate: self.currentStop!.coordinate, addressDictionary: nil)))
                _locationToCurrentStopDirections = MKDirections(request: request)
            }
            return _locationToCurrentStopDirections
        }
        set (newValue) {
            _locationToCurrentStopDirections = newValue
        }
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

    /**
    Initializes `stopStepResponses` with all nils, then populates. Calls callback while populating.
    */
    func calculatePickupToDropoffRoutePiecesWithUpdateCallback(callback: ((updatedArray: [MKDirectionsResponse?], error: NSError?) -> (Void))){
        if stopStepResponses != nil {
            return callback(updatedArray: self.stopStepResponses!, error: nil)
        }
        let allStops = pickups + dropoffs
        stopStepResponses = [MKDirectionsResponse?](count: Int(allStops.count-1), repeatedValue: nil)
        for (index, stop) in enumerate(allStops){
            if (index + 1 < allStops.count){
                var nextStop = allStops[index+1]
                stopToStopDirections(stop, second: nextStop)?.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse!, error: NSError!) -> Void in
                    self.stopStepResponses![index] = response
                    if error != nil {
                        println("error in calculateRoutePieces: " + error.description)
                    }
                    callback(updatedArray: self.stopStepResponses!, error: error)
                }
            }
        }
    }
    
    func calculatePickupToDropoffRouteWithCallback(callback: MKDirectionsHandler!) {
        if pickupToDropoffResponse != nil {
            return callback(pickupToDropoffResponse, nil)
        }
        pickupToDropoffDirections?.calculateDirectionsWithCompletionHandler(callback)
    }

    func calculateLocationToCurrentStopRouteWithCallback(callback: MKDirectionsHandler!) {
        onLocationToCurrentStopRouteDetermined = callback
        if locationToCurrentStopResponse != nil {
            return callback(locationToCurrentStopResponse, nil)
        }
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager.delegate = self
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            self.locationManager(locationManager, didChangeAuthorizationStatus: CLLocationManager.authorizationStatus())
        }
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status.rawValue < CLAuthorizationStatus.AuthorizedAlways.rawValue {
            return
        }
        if locationToCurrentStopDirections?.calculating == true {
            return
        }
        locationToCurrentStopDirections?.calculateDirectionsWithCompletionHandler({ (response: MKDirectionsResponse!, error: NSError!) -> Void in
            self.locationToCurrentStopResponse = response
            self.onLocationToCurrentStopRouteDetermined!(response, error);
        })
    }
}
