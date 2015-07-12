//
//  LocationVC + Layout.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension LocationVC {
    
    func setupLabels() {
        var textColor = rgb(106, 192, 139)
        var textFont = UIFont(name: "Raleway-Bold", size: 17)
        
        destinationLocationLabel = UILabel(frame: CGRectZero)
        destinationLocationLabel.text = "Destination"
        destinationLocationLabel.font = textFont
        destinationLocationLabel.textColor = textColor
        destinationLocationLabel.sizeToFit()
        
        startLocationLabel = UILabel(frame: CGRectZero)
        startLocationLabel.text = "Origin"
        startLocationLabel.font = textFont
        startLocationLabel.textColor = textColor
        startLocationLabel.sizeToFit()
        
        eventLabel = UILabel(frame: CGRectZero)
        eventLabel.text = "Event"
        eventLabel.font = textFont
        eventLabel.textColor = textColor
        eventLabel.sizeToFit()
    }
    
    func setupButtons() {
        var image = UIImage(named: "location_up")
        destLocationButton = UIButton(frame: CGRectMake(0, 0, 55, 55))
        destLocationButton.setImage(image, forState: .Normal)
        destLocationButton.addTarget(self, action: "destButtonTapped:", forControlEvents: .TouchUpInside)
        
        startLocationButton = UIButton(frame: CGRectMake(0, 0, 55, 55))
        startLocationButton.setImage(image, forState: .Normal)
        startLocationButton.addTarget(self, action: "startLocationButtonTapped:", forControlEvents: .TouchUpInside)
        
        eventButton = UIButton(frame: CGRectMake(0, 0, 55, 55))
        eventButton.setImage(image, forState: .Normal)
        eventButton.addTarget(self, action: "eventButtonTapped:", forControlEvents: .TouchUpInside)
    }
    
    func setupImageViews() {
        doubleArrow = UIImageView(frame: CGRectMake(0, 0, 35, 39))
        doubleArrow.image = UIImage(named: "roundTrip")
        
        arrow1 = UIImageView(frame: CGRectMake(0, 0, 30, 20))
        arrow1.image = UIImage(named: "arrow")
        
        arrow2 = UIImageView(frame: CGRectMake(0, 0, 30, 20))
        arrow2.image = UIImage(named: "arrow")
    }
    
    func setupSubviews() {
        setupLabels()
        setupButtons()
        setupImageViews()
        
        switchBackgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
        switchBackgroundView.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        
        var vs = [startLocationButton, startLocationLabel, destLocationButton,
            destinationLocationLabel, eventButton, eventLabel, arrow1, arrow2, doubleArrow]
        for v in vs {
            view.addSubview(v)
        }
    }
    
    func relayout() {
        if layoutSame {
            setOriginDestinationSameLayout()
        } else {
            setOriginEventDestinationLayout()
        }
    }
    
    func setOriginDestinationSameLayout() {
        showOptionalViews(false)
        layoutSubviewSame()
    }
    
    func setOriginEventDestinationLayout() {
        showOptionalViews(true)
        layoutSubviewNotSame()
    }
    
    func layoutSubviewSame() {
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
    
    func layoutSubviewNotSame() {
        var x = view.w / 6.0
        startLocationButton.center.x = x * 1.0
        arrow1.center.x = x * 2.0
        eventButton.center.x = x * 3.0
        arrow2.center.x = x * 4.0
        destLocationButton.center.x = x * 5.0
        
        var y = view.h * 0.3
        startLocationButton.center.y = y
        arrow1.center.y = y
        eventButton.center.y = y
        arrow2.center.y = y
        destLocationButton.center.y = y
        
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