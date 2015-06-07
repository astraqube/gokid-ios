//
//  UIView+Pop.swift
//  WeRead
//
//  Created by Bingwen Fu on 8/17/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

extension UIView {
    
    func springScaleTo(scale: CGFloat, bounciness: CGFloat) {
        var anim = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        anim.toValue = scaleMake(scale)
        anim.springBounciness = bounciness
        self.pop_addAnimation(anim, forKey: "scale_animation")
    }
    
    func alphaAnimation(toValue: CGFloat, duration: CFTimeInterval) {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = toValue
        anim.duration = duration
        self.pop_addAnimation(anim, forKey: "alpha_animation")
    }
    
    func alphaAnimation(toValue: CGFloat, duration: CFTimeInterval, completion: ((POPAnimation!, Bool)->Void)? = nil) {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.toValue = toValue
        anim.duration = duration
        anim.completionBlock = completion
        self.pop_addAnimation(anim, forKey: "alpha_animation")
    }
    
    func positionAnimation(toValue: CGRect, duration: CFTimeInterval) {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        anim.toValue = NSValue(CGRect:toValue)
        anim.duration = duration
        self.pop_addAnimation(anim, forKey: "frame_animation")
    }
    
    func scaleAnimation(toValue: CGPoint, duration: CFTimeInterval) {
        var anim = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        anim.toValue = NSValue(CGPoint:toValue)
        anim.duration = duration
        self.pop_addAnimation(anim, forKey: "scaleXY_animation")
    }
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    
    var w: CGFloat {
        get {
            return self.frame.size.width
        }
    }
    
    var h: CGFloat {
        get {
            return self.frame.size.height
        }
    }
    
    func setRounded() {
        self.layer.cornerRadius = self.w/2.0
        self.clipsToBounds = true
    }
}

extension CALayer {
    func opacityAnimation(toValue: CGFloat, duration: CFTimeInterval) {
        var anim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        anim.toValue = toValue
        anim.duration = duration
        self.pop_addAnimation(anim, forKey: "opacity_animation")
    }
}

