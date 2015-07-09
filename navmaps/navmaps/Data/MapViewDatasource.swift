//
//  MapViewDatasource.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/8/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit

enum MapViewDataSourceType : Int {
    case Detail
    case Driving
}

typealias AnnotationSelectHandler = ((selectedAnnotationView: MKAnnotationView) -> (Void))

class MapViewDatasource: NSObject, MKMapViewDelegate {
    var type : MapViewDataSourceType
    var navigation : Navigation
    
    @IBInspectable var polylineColor : UIColor? = UIColor(red: 42.0/255.0, green: 170.0/255.0, blue: 87.0/255.0, alpha: 1);
    weak var mapView: MKMapView!
    /// We automatically fit UserLocation and MapPins once, when we first display
    var didFitMapOnce = false
    var locationToCurrentStopRoute : MKRoute? {
        willSet { mapView.removeOverlay(self.locationToCurrentStopRoute?.polyline) }
        didSet { mapView.addOverlay(self.locationToCurrentStopRoute?.polyline) }
    }
    
    ///Set me to support Tap handling of Tap events from `mapView:didSelectAnnotationView:`
    var onAnnotationSelect : AnnotationSelectHandler?
    
    ///Re-use your Navigation, where available. After init set me as your `MKMapView`'s delegate, then call `setup()` on me.
    init(type: MapViewDataSourceType, navigation: Navigation, mapView: MKMapView) {
        self.type = type
        self.navigation = navigation
        self.mapView = mapView
    }
    
    ///adds navigation's annotations, sets initially visible pins, starts getting route
    func setup() {
        mapView.addAnnotations(navigation.pickups + navigation.dropoffs)
        mapView.showAnnotations(navigation.pickups + navigation.dropoffs, animated: false)
        updateRoutes()
    }
    
    func updateRoutes() {
        navigation.calculatePickupToDropoffRoutePiecesWithUpdateCallback { (updatedArray: [MKDirectionsResponse?], error: NSError?) -> (Void) in
            if error != nil {
                UIAlertView(title: "Problem showing route", message: "You will still be able to navigate", delegate: nil, cancelButtonTitle: "Okay").show()
            }
            self.displayStaticRoutes()
        }
        
        if type == .Driving {
            navigation.calculateLocationToCurrentStopRouteWithCallback({ (response: MKDirectionsResponse?, error: NSError!) -> Void in
                if error != nil {
                    UIAlertView(title: "Problem showing route from your location", message: "Tap a stop to get directions in Maps", delegate: nil, cancelButtonTitle: "Okay").show()
                }
                self.locationToCurrentStopRoute = response?.routes!.first as? MKRoute
            })
        }
    }

    func displayStaticRoutes() {
        let allStops = navigation.pickups + navigation.dropoffs
        let overlaysSet = (self.mapView.overlays != nil) ?  NSSet(array: self.mapView.overlays) : NSSet()
        for (index, response) in enumerate(navigation.stopStepResponses!) {
            let stopFor = allStops[index]
            if response != nil {
                var route : MKRoute? = response!.routes.first as? MKRoute
                if let poly : MKPolyline? = route?.polyline {
                    if stopFor.hasStopped == true {
                        mapView.removeOverlay(poly)
                    }else if overlaysSet.containsObject(poly!) == false {
                        mapView.addOverlay(poly)
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        onAnnotationSelect?(selectedAnnotationView: view)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if !didFitMapOnce {
            var annotations = ([mapView.userLocation] as [MKAnnotation])
            if type == .Driving {
                annotations.append(navigation.pickups.first!)
            }else {
                annotations.extend(navigation.pickups + navigation.dropoffs as [MKAnnotation])
            }
            mapView.showAnnotations(annotations, animated: true)
            didFitMapOnce = true
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        var reuseID = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        annotationView.image = imageForStopAnnotation(annotation as! Stop)
        return annotationView
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polyline = overlay as? MKPolyline {
            var lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = polylineColor
            lineRenderer.lineWidth = 5;
            return lineRenderer
        }
        return nil
    }
    
    func imageForStopAnnotation(stop: Stop) -> UIImage {
        var pinImageView = UIImageView(frame: CGRectMake(0, 0, 48, 55))
        pinImageView.image = UIImage(named: "pin")!
        pinImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        var renderView = UIView(frame: CGRectMake(0, 0, 62, 79))
        renderView.addSubview(pinImageView)
        
        if stop.thumbnailImage != nil {
            var iconImageView = MapUserImageView(frame: CGRectMake(0, 0, 38, 38))
            iconImageView.cornerRadius = 19
            iconImageView.image = stop.thumbnailImage
            pinImageView.addSubview(iconImageView)
            iconImageView.center = pinImageView.center
            iconImageView.center.y -= 3
        } else {
            var abbreviation : String?
            if stop.name.length >= 2 {
                abbreviation = stop.name.substringToIndex(2)
            }else{
                abbreviation = stop.name.substringToIndex(stop.name.length)
            }
            var words = stop.name.componentsSeparatedByString(" ")
            if words.count > 1 {
                abbreviation = words[0].substringToIndex(1) + words[1].substringToIndex(1)
            }
            
            var iconLabel = UILabel(frame: CGRectMake(0, 0, 38, 38))
            iconLabel.text = abbreviation
            iconLabel.textAlignment = .Center
            iconLabel.textColor = UIColor.whiteColor()
            pinImageView.addSubview(iconLabel)
            iconLabel.center = pinImageView.center
            iconLabel.center.y -= 3
        }
        
        UIGraphicsBeginImageContextWithOptions(renderView.frame.size, false, 0.0)
        renderView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
}
