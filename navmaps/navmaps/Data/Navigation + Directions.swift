//
//  Navigation + Directions.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/20/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

extension Navigation {
    func startUpdatingDirectionsWithCallback(callback : DirectionCallback) {
        if analyzeRouteTimer != nil {
            stopUpdatingDirections()
        }
        onDirectionUpdate = callback
        analyzeRouteTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "analyzeRoute", userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "recalculateRoute", name: UIApplicationWillEnterForegroundNotification, object: nil)
        recalculateRoute()
    }
    
    func recalculateRoute() {
        if locationToCurrentStopResponse != nil {
            locationToCurrentStopResponse = nil
            locationToCurrentStopDirections = nil
            onDirectionUpdate!(error: nil, nextDirection : "Recalculating…")
        }
        calculateLocationToCurrentStopRouteWithCallback { (response: MKDirectionsResponse!, calcError: NSError!) -> Void in
            self.onLocationToCurrentStopRouteDetermined = nil
            var error : NSString?
            if let stop = self.currentStop {
                if let directionsResponse = response {
                    if let route = directionsResponse.routes.first as? MKRoute? {
                        self.currentRoute = route
                        self.currentRouteStepIndex = -1
                    } else { error = "No route to current stop" }
                } else { error = "couldn't get directions to stop\n\(calcError.localizedFailureReason != nil ? calcError.localizedFailureReason! : calcError.localizedDescription)" }
                
            } else { error = "no current step" }
            if error != nil {
                UIAlertView(title: "Navigation Error", message: error! as String, delegate: nil, cancelButtonTitle: "Okay").show()
                self.onDirectionUpdate!(error: nil, nextDirection : "Navigation")
                self.stopUpdatingDirections()
            }
        }
    }
    
    func analyzeRoute() {
        if NSThread.isMainThread(){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.analyzeRoute()
            })
            return
        }
        
        //Navigation next step: currentStep until closer to nextStep.firstPoint than currentStep.lastPoint
        //Navigation off-route: if closest distance from currentStep.path.allPoints > 300 ft, recalculate
        var currentRouteStep = (currentRoute?.steps.count > currentRouteStepIndex && currentRouteStepIndex >= 0 ? currentRoute?.steps[currentRouteStepIndex] : nil) as! MKRouteStep?
        var nextRouteStep = (currentRoute?.steps.count > currentRouteStepIndex + 1 ? currentRoute?.steps[currentRouteStepIndex + 1] : nil) as! MKRouteStep?
        var readyForNextStep = false
        if nextRouteStep != nil && currentRouteStep == nil {
            readyForNextStep = true
        } else if nextRouteStep != nil && currentRouteStep != nil {
            var currentLastCoordinate = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(1)
            var nextFirstCoordinate = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(1)
            var currentPointCount = currentRouteStep!.polyline.pointCount
            currentRouteStep?.polyline.getCoordinates(currentLastCoordinate, range: NSMakeRange(currentPointCount - 2, 1))
            nextRouteStep?.polyline.getCoordinates(nextFirstCoordinate, range: NSMakeRange(0, 1))
            
            var currentDistance = lastLocation?.distanceFromLocation(CLLocation(latitude: currentLastCoordinate[0].latitude, longitude: currentLastCoordinate[0].longitude))
            var nextDistance = lastLocation?.distanceFromLocation(CLLocation(latitude: nextFirstCoordinate[0].latitude, longitude: nextFirstCoordinate[0].longitude))
            
            if nextDistance < currentDistance {
                readyForNextStep = true
            }
            
            currentLastCoordinate.dealloc(1)
            nextFirstCoordinate.dealloc(1)
        }

        //determine if off route
        if readyForNextStep == false && currentRouteStep != nil {
            var currentPointCount = currentRouteStep!.polyline.pointCount
            var currentCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(currentPointCount)
            currentRouteStep?.polyline.getCoordinates(currentCoordinates, range: NSMakeRange(0, currentPointCount))
            
            let recalculateDistance : CGFloat = 150.0
            var minDistance : CGFloat = 999999.9999
            for var i = 0; i < currentPointCount - 1 - 1; i++ {
                var lp1 = CLLocation(latitude: currentCoordinates[i].latitude, longitude: currentCoordinates[i].longitude)
                var lp2 = CLLocation(latitude: currentCoordinates[i + 1].latitude, longitude: currentCoordinates[i + 1].longitude)
                var lp1f = CGPointMake(CGFloat(lp1.coordinate.latitude), CGFloat(lp1.coordinate.longitude))
                var lp2f = CGPointMake(CGFloat(lp2.coordinate.latitude), CGFloat(lp2.coordinate.longitude))
                var pf = CGPointMake(CGFloat(lastLocation!.coordinate.latitude), CGFloat(lastLocation!.coordinate.longitude))
                
                var distance = distanceFromLinePoints(lp1f, lp2: lp2f, point: pf)
                var meterDistance = distance * 111 * 1000  //1 degree of latidude is 111 kilometers, 1000 m/km
                
                if meterDistance < minDistance {
                    minDistance = meterDistance
                }
            }
            if currentPointCount == 1 {
                minDistance = CGFloat(lastLocation!.distanceFromLocation(CLLocation(latitude: currentCoordinates[0].latitude, longitude: currentCoordinates[0].longitude)))
            }
            
            if minDistance > recalculateDistance {
                dispatch_async(dispatch_get_main_queue()) {
                    self.recalculateRoute()
                }
            }
            currentCoordinates.dealloc(currentPointCount)
        }
        
        //if closer to last point of next step
        if readyForNextStep {
            var newStep = nextRouteStep
            currentRouteStepIndex++
            dispatch_async(dispatch_get_main_queue()) {
                self.onDirectionUpdate!(error: nil, nextDirection : nextRouteStep?.instructions)
            }
        }
    }
    
    ///Gets the Perpandicular Distance from a point to a line specifified by the coordinates
    func distanceFromLinePoints(lp1: CGPoint, lp2: CGPoint, point: CGPoint) -> CGFloat {
        var numerator =  fabsf(Float((lp2.y - lp1.y) * point.x - (lp2.x - lp1.x) * point.y + lp2.x * lp1.y - lp2.y * lp1.x))
        var dlp1lp2 = sqrtf(powf(Float(lp2.y - lp1.y),2.0) + powf(Float(lp2.x - lp1.x),2.0) )
        var lineDistance = numerator / dlp1lp2
        
        var dpointlp1 = sqrtf(powf(Float(point.y - lp1.y),2.0) + powf(Float(point.x - lp1.x),2.0) )
        var dpointlp2 = sqrtf(powf(Float(point.y - lp2.y),2.0) + powf(Float(point.x - lp2.x),2.0) )
        
        if dpointlp1 > dlp1lp2 && dpointlp2 > dlp1lp2 {
            return CGFloat(min(dpointlp1, dpointlp2))
        } else {
            return CGFloat(lineDistance)
        }
    }
    
    func stopUpdatingDirections() {
        if analyzeRouteTimer != nil {
            analyzeRouteTimer?.invalidate()
        }
        analyzeRouteTimer = nil
        onDirectionUpdate = nil
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
}