//
//  CalendarUserImageView.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

@IBDesignable
class CalendarUserImageView: UIImageView {
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.blackColor() {
        didSet {
            layer.borderColor = borderColor.CGColor;
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.borderWidth = CGFloat(3.5)
        self.borderColor = ColorManager.sharedInstance.appLightGreen
    }
}
