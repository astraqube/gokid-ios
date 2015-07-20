//
//  ETACalculator.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/20/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import CoreLocation

class ETACalculator {
    static let metersPerSecond = 8.9408 //20 mph
    ///returns tuples of minutes from first stop
    class func estimateArrivalTimeForStops(stops: [Stop]) -> [(Double, Stop)]{
        var travelTimes = [(Double, Stop)]()
        for (index, stop) in enumerate(stops) {
            if index == 0 {
                travelTimes.append((0, stop))
                continue
            }
            let lastStop = stops[index - 1]
            let lastLocation = CLLocation(latitude: lastStop.coordinate.latitude, longitude: lastStop.coordinate.longitude)
            let distance = lastLocation.distanceFromLocation(CLLocation(latitude: stop.coordinate.latitude, longitude: stop.coordinate.longitude))
            let seconds = distance / metersPerSecond
            let prevSeconds = travelTimes[index - 1].0
         
            travelTimes.append((seconds +  prevSeconds, stop))
        }
        return travelTimes
    }
    
    ///Use distances to naively sort stops such that they are in increasing distance from the first stop
    class func sortStops(inout stops: [Stop], beginningAt : Stop?) {
        let firstCoord = beginningAt?.coordinate
        let firstLocation = CLLocation(latitude: firstCoord!.latitude, longitude: firstCoord!.longitude)
        stops.sort({ (stopA, stopB) -> Bool in
            let distanceA = firstLocation.distanceFromLocation(CLLocation(latitude: stopA.coordinate.latitude, longitude: stopA.coordinate.longitude))
            let distanceB = firstLocation.distanceFromLocation(CLLocation(latitude: stopB.coordinate.latitude, longitude: stopB.coordinate.longitude))
            return distanceA < distanceB
        })
    }
}
