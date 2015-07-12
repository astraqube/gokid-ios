//
//  GKSegmentControl.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class GKSegmentControl: UISegmentedControl {
    
    override func awakeFromNib() {
        var font = UIFont(name: "Raleway-Bold", size: 15)
        var attr = [NSFontAttributeName: font!]
        self.setTitleTextAttributes(attr, forState: .Normal)
    }
}
