//
//  FrequencyHeaderCell.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/28/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class FrequencyHeader: UIView {
    
    var timeLabel = UILabel()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.greenColor()
        
        timeLabel.font = UIFont.systemFontOfSize(16)
        self.addSubview(timeLabel)
        // auto layout
        var insets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10)
        timeLabel.autoPinEdgesToSuperviewEdgesWithInsets(insets)
    }
}
