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
    ///returns tuples of minutes from first stop -- stops are not sorted here
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
    /// `beginningAt` is a member of stops
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
    
    ///A little bit of AI to sort stops guaranteed optimally
    class func superSortStops(stops: [Stop], beginningAt : Stop, endingAt : Stop) -> [Stop]{
        //initialize
        var exploreQueue = [EdgePath(origin: beginningAt, destination: beginningAt, previousEdge: nil, lastStop: endingAt, remainingStops: Set(stops).subtract([beginningAt]))] //sets weight = 0, etc
        //run
        var bestPath : EdgePath?
        while exploreQueue.count > 0 && bestPath == nil {
            let next = exploreQueue.removeLast()
            if next.edgeDestination == endingAt {
                bestPath = next
                continue
            }
            exploreQueue.extend(next.nextPathStates())
            exploreQueue.sort { (left, right) -> Bool in
                return left.weight > right.weight //is ordered before
            }
        }
        
        //dump data
        if let bestPath = bestPath {
            var path = [bestPath.edgeDestination]
            var prev = bestPath.previous
            while prev != nil {
                path.append(prev!.edgeDestination)
                prev = prev!.previous
            }
            return path.reverse()
        }

        //fallback in case of two stops
        return stops
    }
}

class EdgePath {
    var weight : Double = DBL_MAX
    var previous : EdgePath?
    let edgeOrigin : Stop
    let edgeDestination : Stop
    let remainingStops : Set<Stop>
    ///lastStop is explored last, not included in nextPathStates unless all other stops completed
    ///lastStop is a member of remainingStops
    var lastStop : Stop
    
    init(origin: Stop, destination: Stop, previousEdge: EdgePath?, lastStop: Stop, remainingStops: Set<Stop>){
        edgeOrigin = origin
        edgeDestination = destination
        previous = previousEdge
        self.lastStop = lastStop
        self.remainingStops = remainingStops
        
        //calc weight
        let origin = CLLocation(coordinate: origin.coordinate)
        let destination = CLLocation(coordinate: destination.coordinate)
        weight = destination.distanceFromLocation(origin) + (previous != nil ? previous!.weight : 0.0)
    }
    
    func nextPathStates() -> [EdgePath] {
        var next = [EdgePath]()
        var exploring = remainingStops.subtract([lastStop])
        if exploring.count == 0 {
            exploring = [lastStop]
        }
        for stop in exploring {
            next.append(EdgePath(origin: self.edgeDestination, destination: stop, previousEdge: self, lastStop: self.lastStop, remainingStops: self.remainingStops.subtract([stop])))
        }
        return next
    }
}

extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D){
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
