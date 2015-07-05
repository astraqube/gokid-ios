//
//  BorderedView.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/4/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {
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
}
