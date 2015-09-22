//
//  HelperFunction + NSDate.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/20/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import Foundation

extension NSDate {
    func iso8601String() -> String {
        let df = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.locale = enUSPosixLocale
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZZZZZ"
        print(df.stringFromDate(self))
        return df.stringFromDate(self)
    }
    
    class func dateFromIso8601String(str: String) -> NSDate? {
        let df = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        df.locale = enUSPosixLocale
        if let date = df.dateFromString(str) {
            return date
        } else {
            return nil
        }
    }
    
    func dateString() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "EE MMMM d, YYYY"
        return df.stringFromDate(self)
    }
    
    func shortDateString() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "EE MMMM d"
        return df.stringFromDate(self)
    }
    
    func timeString() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "hh:mma"
        return df.stringFromDate(self).lowercaseString
    }
    
    func weekDayString() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "EE"
        return df.stringFromDate(self)
    }
    
    func weekDayFullString() -> String {
        let df = NSDateFormatter()
        df.dateFormat = "EEEE"
        return df.stringFromDate(self)
    }

    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }
    
}
