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
    
    let lightGrayColor = rgb(230,230,230)
    let darkGrayColor = rgb(167,167,167)
    let disableColor = rgb(100, 100, 100)
    let appGreen = rgb(103, 193, 139)
    let appLightGreen = rgb(237, 249, 237)
    let appNavTextButtonColor = rgb(81, 118, 115)
    let appDarkGreen = rgb(79, 118, 115)

    // MARK: Primary Colors
    let color67C18B = rgb(103, 193, 139)
    let color456462 = rgb(69, 100, 98)
    let color485F49 = rgb(72, 95, 73)
    let color2EB56A = rgb(46, 181, 106)
    
    // MARK: Secondary Colors
    let color6E9695 = rgb(110, 150, 149)
    let color92BC9E = rgb(146, 188, 158)
    let color88B8B8 = rgb(136, 184, 184)
    let colorBAD3B4 = rgb(186, 211, 180)
    let color9AB7B7 = rgb(154, 183, 183)
    let color507573 = rgb(80, 117, 115)
    
    // MARK: Tertiary Colors
    let colorF9FCF5 = rgb(249, 252, 245)
    let colorEBF7EB = rgb(235, 247, 235)
    let colorD4EDDC = rgb(212, 237, 220)
}
