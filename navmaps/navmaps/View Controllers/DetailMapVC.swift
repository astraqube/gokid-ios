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
        annotationView.image = UIImage(named: "pin")
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
}
