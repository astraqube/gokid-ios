//
//  DrivingModeVC.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/3/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit

class DrivingModeVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionsLabel: UILabel!
    var mapDataSource : MapViewDatasource!
    var navigation : Navigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapDataSource = MapViewDatasource(type: .Driving, navigation: navigation, mapView: mapView)
        mapView.delegate = mapDataSource
        mapDataSource.setup()
        
        navigation.onDirectionUpdate = { (error: NSError?, nextDirection : NSString) -> (Void) in
            if error != nil {
                UIAlertView(title: "Navigation Error!", message: "You can resume where you left off", delegate: nil, cancelButtonTitle: "Okay").show()
                return self.exitPressed(self)
            }
            self.directionsLabel.text = nextDirection as String
        }

        mapDataSource.onAnnotationSelect = { (annotationView: MKAnnotationView) -> Void in
            if let stop = annotationView.annotation as? Stop {
                var stopActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                var stopTitle = stop.hasStopped == false ? "Pickup " + (stop.name as String) : "Undo Pickup"
                if (self.navigation.dropoffs as NSArray).containsObject(stop) == true {
                    stopTitle = stop.hasStopped == false ? "Dropoff " + (stop.name as String) : "Undo Dropoff"
                }
                stopActionSheet.addAction(UIAlertAction(title: stopTitle, style: UIAlertActionStyle.Destructive, handler: { (z: UIAlertAction!) -> Void in
                    stop.hasStopped = !stop.hasStopped
                    self.navigation.updateForStopped()
                    self.mapDataSource.updateRoutes()
                    self.mapDataSource.updateMapTrack()
                    self.checkIfDone()
                }))
                if stop.phoneNumber != nil {
                    stopActionSheet.addAction(UIAlertAction(title: "Send Message", style: UIAlertActionStyle.Default, handler: { (z: UIAlertAction!) -> Void in
                        UIApplication.sharedApplication().openURL(NSURL(string: "sms:\(stop.phoneNumber)")!)
                    }))
                }
                stopActionSheet.addAction(UIAlertAction(title: "Navigate in Maps", style: UIAlertActionStyle.Default, handler: { (z: UIAlertAction!) -> Void in
                    var mapItem = MKMapItem(placemark: MKPlacemark(coordinate: stop.coordinate, addressDictionary: nil))
                    mapItem.name = stop.name as String
                    MKMapItem.openMapsWithItems([mapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapCenterKey : NSValue(MKCoordinate: self.mapView.region.center), MKLaunchOptionsMapSpanKey : NSValue(MKCoordinateSpan: self.mapView.region.span)])
                }))
                stopActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(stopActionSheet, animated: true, completion: nil)
            }
        }
    }

    func checkIfDone() {
        if navigation.currentStop == nil {
            var alert = UIAlertController(title: "Completed!", message: "Nice work, route complete!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default , handler: { (action: UIAlertAction!) -> Void in
                self.exitPressed(self)
            }))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeTrackModeRecognized(sender: UIGestureRecognizer) {
        mapDataSource.toggleTrackMode()
    }
    
    @IBAction func exitPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
