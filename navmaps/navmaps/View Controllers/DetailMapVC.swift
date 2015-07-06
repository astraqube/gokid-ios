//
//  DetailMapVC.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/3/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit

class DetailMapVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBInspectable var polylineColor : UIColor?
    
    /// We automatically fit UserLocation and MapPins once
    var didFitMapOnce = false
    
    var navigation : Navigation!
    var pickupDropoffRoute : MKRoute? {
        willSet {
            self.mapView.removeOverlay(self.pickupDropoffRoute?.polyline)
        }
        didSet {
            self.mapView.addOverlay(self.pickupDropoffRoute?.polyline)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.addAnnotation(self.navigation.dropoff)
        self.mapView.addAnnotation(self.navigation.pickup)

        navigation.calculatePickupToDropoffRouteWithCallback { (response: MKDirectionsResponse!, error: NSError!) -> Void in
            self.pickupDropoffRoute = response.routes.first as? MKRoute
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if !didFitMapOnce {
            var annotations = [mapView.userLocation, self.navigation.pickup]
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
        if overlay as? MKPolyline == pickupDropoffRoute!.polyline {
            var lineRenderer = MKPolylineRenderer(polyline: pickupDropoffRoute!.polyline)
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
