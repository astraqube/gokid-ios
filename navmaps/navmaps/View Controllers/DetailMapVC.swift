//
//  DetailMapVC.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/3/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import MapKit

class DetailMapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var mapDataSource : MapViewDatasource!
    var navigation : Navigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapDataSource = MapViewDatasource(type: .Detail, navigation: navigation, mapView: mapView)
        mapView.delegate = mapDataSource
        mapDataSource.setup()
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let drivingModeVC = segue.destinationViewController as? DrivingModeVC {
            drivingModeVC.navigation = navigation
        }
    }
}
