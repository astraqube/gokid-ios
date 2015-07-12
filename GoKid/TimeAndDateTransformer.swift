//
//  TimeAndDateTransformer.swift
//  GoKid
//
//  Created by Dean Quinanola on 7/12/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//


class DateTransformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            if valueData.isKindOfClass(NSDate) {
                let date = valueData as! NSDate
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                return dateFormatter.stringFromDate(date)
            }
        }
        return nil
    }
}


class TimeTransformer: NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            if valueData.isKindOfClass(NSDate) {
                let date = valueData as! NSDate
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                return dateFormatter.stringFromDate(date)
            }
        }
        return nil
    }
}
