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
    @IBOutlet weak var trayOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTrayNavView: UIView!
    @IBOutlet weak var bottomTrayView: UIView!
    var mapDataSource : MapViewDatasource!
    var navigation : Navigation!
    
    var trayShown : Bool {
        get { return trayOffsetConstraint.constant != 0 }
        set(newValue) {
            let constant = newValue ? trayShowConstraintOffset : 0
            trayOffsetConstraint.constant = constant
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    var trayShowConstraintOffset : CGFloat {
        get { return bottomTrayView.frame.size.height - bottomTrayNavView.frame.size.height }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapDataSource = MapViewDatasource(type: .Detail, navigation: navigation, mapView: mapView)
        mapView.delegate = mapDataSource
        mapDataSource.setup()
    }
 
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let drivingModeVC = segue.destinationViewController as? DrivingModeVC {
            drivingModeVC.navigation = navigation
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    @IBAction func onTrayTap(sender: UITapGestureRecognizer) {
        trayShown = !trayShown
    }
    
    var initialOffset : CGFloat = 0
    @IBAction func onTrayPan(sender: UIPanGestureRecognizer) {
        var translationY = sender.translationInView(view).y * -1
        var velocityY = sender.velocityInView(view).y * -1
        if sender.state == .Began {
            initialOffset = trayOffsetConstraint.constant
        } else if sender.state == .Changed {
            var newOffset = initialOffset + translationY
            var overshoot = newOffset - trayShowConstraintOffset
            if overshoot > 0 {
                newOffset = trayShowConstraintOffset + overshoot/6
            }
            trayOffsetConstraint.constant = newOffset
        } else if sender.state == .Ended {
            trayShown = velocityY > 0
        }
    }
}
