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
    @IBOutlet var heightConstraint : NSLayoutConstraint!
    @IBOutlet var borderedView : BorderedView!
    @IBOutlet var userImageView : CalendarUserImageView!
    
    @IBOutlet var dotsImageView : UIImageView?
}
