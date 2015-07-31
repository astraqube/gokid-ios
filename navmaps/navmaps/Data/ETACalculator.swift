//
//  ETACalculator.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/20/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import CoreLocation

class ETACalculator {
    static let pickupStopLength = 60.0*5.0 //5 minute pickup
    static let metersPerSecond = 11.176 //25 mph
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
            //extra minutes to get to next stop based on pickup length
            let seconds = distance / metersPerSecond + pickupStopLength
            let prevSeconds = travelTimes[index - 1].0
         
            travelTimes.append((seconds +  prevSeconds, stop))
        }
        return travelTimes
    }
    
    ///returns array of departure dates for each stop, in order 
    class func stopDatesFromEstimatesAndArrivalTargetDate(etas: [(Double, Stop)], target: NSDate?) -> [(NSDate, Stop)]{
        if etas.count == 0 { return [] }
        var startAtNow : Bool = true
        if target != nil && NSDate(timeIntervalSinceNow: etas.last!.0).timeIntervalSince1970 <= target!.timeIntervalSince1970 {
            startAtNow = false
        }
        var etaDates = [NSDate]()
        if startAtNow {
            return etas.map { (tuple: (Double, Stop)) -> (NSDate, Stop) in
                return (NSDate(timeIntervalSinceNow: tuple.0), tuple.1)
            }
        }else {
            return etas.map { (tuple: (Double, Stop)) -> (NSDate, Stop) in
                let interval = tuple.0 - etas.last!.0
                return (target!.dateByAddingTimeInterval(interval), tuple.1)
            }
        }
    }
    
    ///Use distances to naively sort stops such that they are in increasing distance from the first stop
    class func sortStops(inout stops: [Stop], beginningAt : Stop?) {
        if stops.count == 0 || beginningAt == nil { return }
        let firstCoord = beginningAt?.coordinate
        let firstLocation = CLLocation(latitude: firstCoord!.latitude, longitude: firstCoord!.longitude)
        stops.sort({ (stopA, stopB) -> Bool in
            let distanceA = firstLocation.distanceFromLocation(CLLocation(latitude: stopA.coordinate.latitude, longitude: stopA.coordinate.longitude))
            let distanceB = firstLocation.distanceFromLocation(CLLocation(latitude: stopB.coordinate.latitude, longitude: stopB.coordinate.longitude))
            return distanceA < distanceB
        })
    }
}
