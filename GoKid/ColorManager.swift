//
//  ColorManager.swift
//  GoKid
//
//  Created by Bingwen Fu on 6/6/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

class ColorManager: NSObject {
    
    class var sharedInstance : ColorManager {
        struct Static {
            static let instance : ColorManager = ColorManager()
        }
        return Static.instance
    }
    
    let blueColor = rgb(0, 143, 254)
    let lightGrayColor = rgb(230,230,230)
    let darkGrayColor = rgb(167,167,167)
    let disableColor = rgb(100, 100, 100)
    let appGreen = rgb(103, 193, 139)
}
