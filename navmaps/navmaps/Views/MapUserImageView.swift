//
//  MapUserImageView.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/4/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit

@IBDesignable
class MapUserImageView: UIImageView {
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
