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
        layoutNotSame()
    }
    
    func layoutSame() {
        var x = view.w / 4.0
        startLocationButton.center.x = x * 1.0
        doubleArrow.center.x = x * 2.0
        eventButton.center.x = x * 3.0
        
        var y = view.h * 0.3
        startLocationButton.center.y = y
        doubleArrow.center.y = y
        eventButton.center.y = y
        associateLabelWithButton()
    }
    
    func layoutNotSame() {
        var x = view.w / 6.0
        startLocationButton.center.x = x * 1.0
        arrow1.center.x = x * 2.0
        eventButton.center.x = x * 3.0
        arrow2.center.x = x * 4.0
        destLocationButton.center.x = x * 5.0
        associateLabelWithButton()
    }
    
    func associateLabelWithButton() {
        startLocationLabel.center.x = startLocationButton.center.x
        eventLabel.center.x = eventButton.center.x
        destinationLocationLabel.center.x = destLocationButton.center.x
        
        var insets: CGFloat = 12.0
        startLocationLabel.y = startLocationButton.y + startLocationButton.h + insets
        eventLabel.y = eventButton.y + eventButton.h + insets
        destinationLocationLabel.y = destLocationButton.y + destLocationButton.h + insets
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