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
    @IBOutlet weak var bottomTrayAngleUp: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shortDateLabel: UILabel!
    @IBOutlet weak var pickupIcon: UILabel!
    @IBOutlet weak var dropoffIcon: UILabel!
    
    @IBOutlet var riderImageViews : [CalendarUserImageView]!
    @IBOutlet var riderLabelViews : [UILabel]!
    @IBOutlet var itineraryRows : [MapItineraryItemView]!
    @IBOutlet weak var itineraryScrollView: UIScrollView!
    var mapDataSource : MapViewDatasource!
    var navigation : Navigation!
    
    var trayShown : Bool {
        get { return trayOffsetConstraint.constant != 0 }
        set(show) {
            let constant = show ? trayShowConstraintOffset : 0
            trayOffsetConstraint.constant = constant
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.bottomTrayAngleUp.transform = show ? CGAffineTransformMakeRotation(CGFloat(M_PI)) : CGAffineTransformIdentity
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
        setupView()
    }
    
    func setupView() {
        //if pickups == 1 && dropoffs.count > 1, riders = dropoffs
        //else riders = pickups
        var riders : [Stop]
        if navigation.pickups.count == 1 && navigation.dropoffs.count > 1 {
            riders = navigation.dropoffs
        } else {
            riders = navigation.pickups
        }
        for (index, riderImageView) in enumerate(riderImageViews) {
            let model : Stop? = (riders.count > index) ? riders[index] : nil
            if model != nil {
                setupUserImageView(riderImageView, model: model!)
                riderImageView.hidden = false
            } else {
                riderImageView.hidden = true
            }
        }
        for (index, riderLabelView) in enumerate(riderLabelViews) {
            let model : Stop? = (riders.count > index) ? riders[index] : nil
            if model != nil {
                var firstWord = model!.name.componentsSeparatedByString(" ").first as? NSString
                riderLabelView.text = firstWord as String?
                riderLabelView.hidden = false
            } else {
                riderLabelView.hidden = true
            }
        }
        var stops = self.navigation.pickups + self.navigation.dropoffs
        for (index, itineraryItemView) in enumerate(itineraryRows){
            let model : Stop? = (stops.count > index) ? stops[index] : nil
            if model != nil {
                var titleString = model!.name as String
                if index == 0 {
                    titleString = "Depart from \(titleString)"
                } else if index == (stops.count - 1) {
                    titleString = "Arrive at \(titleString)"
                }
                itineraryItemView.titleLabel.text = titleString
                itineraryItemView.addressLabel.text = model!.address as String?
                setupUserImageView(itineraryItemView.userImageView, model: model!)
                itineraryItemView.collapseHeightConstraint.active = false
                itineraryItemView.hidden = false
            } else {
                itineraryItemView.collapseHeightConstraint.active = true
                itineraryItemView.hidden = true
            }
        }
        itineraryScrollView.layoutIfNeeded()
    }
    
    func setupUserImageView (userImageView : CalendarUserImageView, model: Stop) {
        userImageView.nameString = model.name
        userImageView.image = model.thumbnailImage
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
