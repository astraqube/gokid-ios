//
//  MapItineraryItemView.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/11/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit

@IBDesignable
class MapItineraryItemView: UIView {
    @IBOutlet var timeLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var addressLabel : UILabel!
    @IBOutlet var borderedView : BorderedView!
    @IBOutlet var userImageView : CalendarUserImageView!
    ///We've set them installed=false by default
    ///Install to collapse a row to zero height
    ///We set the userImage container bottom margin to priority 999 to avoid conflict
    @IBOutlet var collapseHeightConstraint : NSLayoutConstraint!
    
    @IBOutlet var dotsImageView : UIImageView?
}
