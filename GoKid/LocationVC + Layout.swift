//
//  LocationVC + Layout.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension LocationVC {
    
    func setOriginDestinationSameLayout() {
        showOptionalViews(false)
        layoutSame()
    }
    
    func setOriginEventDestinationLayout() {
        showOptionalViews(true)
    }
    
    func layoutSame() {
        doubleArrow.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        doubleArrow.autoPinEdge(.Top, toEdge:.Bottom, ofView: taponLabel, withOffset: 20.0)
    }

    
    func showOptionalViews(show: Bool) {
        var vs = [destLocationButton, destinationLocationLabel, arrow1, arrow2]
        for v in vs {
            if show {
                v.alpha = 1.0
                v.userInteractionEnabled = true
            } else {
                v.alpha = 0.0
                v.userInteractionEnabled = false
            }
        }
        
        if show {
            doubleArrow.userInteractionEnabled = false
            doubleArrow.alpha = 0.0
        } else {
            doubleArrow.userInteractionEnabled = true
            doubleArrow.alpha = 1.0
        }
    }
}