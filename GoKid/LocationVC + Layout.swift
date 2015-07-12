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
        
        destinationLocationLabel = UILabel(frame: CGRectMake(0, 0, 105, 120))
        destinationLocationLabel.text = "Sharon park Dr 350, United States"
        destinationLocationLabel.font = UIFont(name: "Raleway", size: 13)
        destinationLocationLabel.textColor = textColor
        destinationLocationLabel.numberOfLines = 0
        destinationLocationLabel.textAlignment = .Center
        destinationLocationLabel.sizeToFit()
        
        startLocationLabel = UILabel(frame: CGRectMake(0, 0, 105, 120))
        startLocationLabel.text = "San Francisco xxxx xxxxxxxxx xxx 1010"
        startLocationLabel.font = UIFont(name: "Raleway", size: 13)
        startLocationLabel.textColor = textColor
        startLocationLabel.textAlignment = .Center
        startLocationLabel.numberOfLines = 0
        startLocationLabel.sizeToFit()
        
        destLabel = UILabel(frame: CGRectZero)
        destLabel.text = "Destination"
        destLabel.font = textFont
        destLabel.textColor = textColor
        destLabel.sizeToFit()
        
        startLabel = UILabel(frame: CGRectZero)
        startLabel.text = "Origin"
        startLabel.font = textFont
        startLabel.textColor = textColor
        startLabel.sizeToFit()
        
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
        
        // iphone 5
        if userManager.windowH < 580 {
            heightRatio = 0.45
        }
        
        switchBackgroundView.layer.borderColor = UIColor.lightGrayColor().CGColor
        switchBackgroundView.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        
        var vs = [startLocationButton, startLocationLabel, destLocationButton,
            destinationLocationLabel, eventButton, eventLabel, arrow1, arrow2, doubleArrow, startLabel, destLabel]
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
        
        var y = view.h * heightRatio
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
        
        var y = view.h * heightRatio
        startLocationButton.center.y = y
        arrow1.center.y = y
        eventButton.center.y = y
        arrow2.center.y = y
        destLocationButton.center.y = y
        
        associateLabelWithButton()
    }
    
    func associateLabelWithButton() {
        startLabel.center.x = startLocationButton.center.x
        eventLabel.center.x = eventButton.center.x
        destLabel.center.x = destLocationButton.center.x
        startLocationLabel.center.x = startLocationButton.center.x
        destinationLocationLabel.center.x = destLocationButton.center.x
        
        var insets: CGFloat = 12.0
        startLabel.y = startLocationButton.y + startLocationButton.h + insets
        eventLabel.y = eventButton.y + eventButton.h + insets
        destLabel.y = destLocationButton.y + destLocationButton.h + insets
        
        startLocationLabel.y = startLabel.y + startLabel.h + insets
        destinationLocationLabel.y = destLabel.y + destLabel.h + insets
    }

    
    func showOptionalViews(show: Bool) {
        var vs = [destLocationButton, destinationLocationLabel, arrow1, arrow2, destLabel]
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