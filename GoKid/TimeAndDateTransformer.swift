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
                return date.dateString()
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
                return date.timeString()
            }
        }
        return nil
    }
}


class FrequencyTransformer: NSValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return false
    }

    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let valueData: AnyObject = value {
            if valueData.isKindOfClass(NSArray) {
                let occurrence = valueData as! NSArray

                if occurrence.count == 0 {
                    return GKFrequency.JustOnce.rawValue

                } else if occurrence.count == 7 {
                    return GKFrequency.Daily.rawValue

                } else {
                    var converted: [String] = []
                    for num in occurrence {
                        let val = num as! Int
                        if contains(GKDays.asKeys.values, val) {
                            let day: String = GKDays.asKeys.keys[find(GKDays.asKeys.values, val)!]
                            converted.append(day)
                        }
                    }
                    return ", ".join(converted)
                }
            }
        }
        return nil
    }
}

