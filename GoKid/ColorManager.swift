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
    
    let lightGrayColor = rgb(230,g: 230,b: 230)
    let darkGrayColor = rgb(167,g: 167,b: 167)
    let disableColor = rgb(100, g: 100, b: 100)
    let appGreen = rgb(103, g: 193, b: 139)
    let appLightGreen = rgb(237, g: 249, b: 237)
    let appNavTextButtonColor = rgb(81, g: 118, b: 115)
    let appDarkGreen = rgb(79, g: 118, b: 115)

    // MARK: Primary Colors
    let color67C18B = rgb(103, g: 193, b: 139)
    let color456462 = rgb(69, g: 100, b: 98)
    let color485F49 = rgb(72, g: 95, b: 73)
    let color2EB56A = rgb(46, g: 181, b: 106)
    
    // MARK: Secondary Colors
    let color6E9695 = rgb(110, g: 150, b: 149)
    let color92BC9E = rgb(146, g: 188, b: 158)
    let color88B8B8 = rgb(136, g: 184, b: 184)
    let colorBAD3B4 = rgb(186, g: 211, b: 180)
    let color9AB7B7 = rgb(154, g: 183, b: 183)
    let color507573 = rgb(80, g: 117, b: 115)
    
    // MARK: Tertiary Colors
    let colorF9FCF5 = rgb(249, g: 252, b: 245)
    let colorEBF7EB = rgb(235, g: 247, b: 235)
    let colorD4EDDC = rgb(212, g: 237, b: 220)

    // MARK: Danger red color
    let colorWarningRed = rgb(217, g: 56, b: 41)
    let colorDangerRed = rgb(172, g: 40, b: 28)
}
