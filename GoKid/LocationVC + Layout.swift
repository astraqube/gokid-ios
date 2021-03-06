//
//  LocationVC + Layout.swift
//  GoKid
//
//  Created by Bingwen Fu on 7/11/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

extension LocationVC {
    
    func setupLabels() {
        var textColor = colorManager.color456462
        var highlightColor = colorManager.color67C18B
        var textFont = UIFont(name: "Raleway-Bold", size: 17)
        var smallTextFont = UIFont(name: "Raleway-Regular", size: 14)
        
        destinationLocationLabel = UILabel(frame: CGRectMake(0, 0, 105, 120))
        destinationLocationLabel.text = "Sharon park Dr 350, United States"
        destinationLocationLabel.font = smallTextFont
        destinationLocationLabel.textColor = textColor
        destinationLocationLabel.numberOfLines = 0
        destinationLocationLabel.textAlignment = .Center
        destinationLocationLabel.sizeToFit()
        
        startLocationLabel = UILabel(frame: CGRectMake(0, 0, 105, 120))
        startLocationLabel.text = "San Francisco xxxx xxxxxxxxx xxx 1010"
        startLocationLabel.font = smallTextFont
        startLocationLabel.textColor = textColor
        startLocationLabel.textAlignment = .Center
        startLocationLabel.numberOfLines = 0
        startLocationLabel.sizeToFit()
        
        eventLocationLabel = UILabel(frame: CGRectMake(0, 0, 105, 120))
        eventLocationLabel.text = "San Francisco xxxx xxxxxxxxx xxx 1010"
        eventLocationLabel.font = smallTextFont
        eventLocationLabel.textColor = textColor
        eventLocationLabel.textAlignment = .Center
        eventLocationLabel.numberOfLines = 0
        eventLocationLabel.sizeToFit()
        
        destLabel = UILabel(frame: CGRectZero)
        destLabel.text = "Dropoff"
        destLabel.font = textFont
        destLabel.textColor = highlightColor
        destLabel.sizeToFit()
        
        startLabel = UILabel(frame: CGRectMake(0, 0, 100, 30))
        startLabel.text = "Pickup & \nDropoff"
        startLabel.font = textFont
        startLabel.textColor = highlightColor
        startLabel.numberOfLines = 0
        startLabel.textAlignment = .Center
        startLabel.sizeToFit()
        
        eventLabel = UILabel(frame: CGRectZero)
        eventLabel.text = "Event"
        eventLabel.font = textFont
        eventLabel.textColor = highlightColor
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

        if rider != nil {
            eventButton.enabled = false
        }
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
            destinationLocationLabel, eventButton, eventLabel, eventLocationLabel,
            arrow1, arrow2, doubleArrow, startLabel, destLabel]
        for v in vs {
            view.addSubview(v)
        }
    }
    
    func relayout() {
        if originDestSame {
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
        startLabel.text = "Pickup & \nDropoff"
        startLabel.frame = CGRectMake(0, 0, 100, 30)
        startLabel.sizeToFit()
        
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
        startLabel.text = "Pickup"
        startLabel.frame = CGRectMake(0, 0, 100, 30)
        startLabel.sizeToFit()
        
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
        eventLocationLabel.center.x = eventButton.center.x
        
        var insets: CGFloat = 12.0
        startLabel.y = startLocationButton.y + startLocationButton.h + insets
        eventLabel.y = eventButton.y + eventButton.h + insets
        destLabel.y = destLocationButton.y + destLocationButton.h + insets
        
        startLocationLabel.y = startLabel.y + startLabel.h + insets
        destinationLocationLabel.y = destLabel.y + destLabel.h + insets
        eventLocationLabel.y = eventLabel.y + eventLabel.h + insets
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

    func toggleForOneWayView() {
        arrow1.hidden = currentPickupOccurrence == nil
        startLocationButton.hidden = currentPickupOccurrence == nil
        startLocationLabel.hidden = currentPickupOccurrence == nil
        startLabel.hidden = currentPickupOccurrence == nil

        arrow2.hidden = currentDropoffOccurrence == nil
        destLocationButton.hidden = currentDropoffOccurrence == nil
        destinationLocationLabel.hidden = currentDropoffOccurrence == nil
        destLabel.hidden = currentDropoffOccurrence == nil

        switchBackgroundView.hidden = isOneWay
    }

}
