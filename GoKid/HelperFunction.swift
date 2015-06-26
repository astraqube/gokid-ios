//
//  HelperFunction.swift
//  WeRead
//
//  Created by Bingwen Fu on 7/7/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

class HelperFunction: NSObject { }

func rotationMake(degree: Double) -> CGAffineTransform {
    return CGAffineTransformMakeRotation(CGFloat(M_PI * (degree) / 180.0))
}

func transFormMake(scale: CGFloat) -> CGAffineTransform {
    return CGAffineTransformMakeScale(scale, scale)
}

func transFormMake(scale: CGPoint) -> CGAffineTransform {
    return CGAffineTransformMakeScale(scale.x, scale.y)
}

func point(x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPointMake(x, y)
}

func pointValue(point:CGPoint) -> NSValue {
    return NSValue(CGPoint:point)
}

func pointValue(x: CGFloat, y: CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPointMake(x, y))
}

func rectValue(x: CGFloat, y: CGFloat, w:CGFloat, h:CGFloat) -> NSValue {
    return NSValue(CGRect: CGRectMake(x, y, w, h))
}

func scaleMake(scale_xy: CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPointMake(scale_xy, scale_xy))
}

func scaleMake(x: CGFloat, y: CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPointMake(x, y))
}

func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
}

func rgba(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func nib(name: String) -> UINib {
    return UINib(nibName: name, bundle: NSBundle.mainBundle())
}

func vcWithID(ID: String) -> UIViewController {
    var sb = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    return sb.instantiateViewControllerWithIdentifier(ID) as! UIViewController
}

extension CGPoint {
    func inRect(rect :CGRect) -> Bool {
        return CGRectContainsPoint(rect, self)
    }
    
    func toValue() -> NSValue {
        return NSValue(CGPoint: self)
    }
}

func time() -> NSTimeInterval {
    return NSDate().timeIntervalSince1970
}

func onGlobalThread(function :(() -> Void)) {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        function()
    }
}

func onMainThread(function :(() -> Void)) {
    dispatch_async(dispatch_get_main_queue()) {
        function()
    }
}

func withDelay(delayInSecond: Double, function :(() -> Void)) {
    var delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSecond * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue()) {
        function()
    }
}

extension NSString {
    func heightForFont(font: UIFont, fixedWidth: CGFloat) -> CGFloat {
        var attri = [NSFontAttributeName : font]
        var attrStr = NSMutableAttributedString(string: self as! String, attributes: attri)
        var rect = attrStr.boundingRectWithSize(CGSizeMake(fixedWidth, 99999.0), options: .UsesLineFragmentOrigin, context: nil)
        return CGFloat(rect.size.height)
    }
}

extension UITableView {
    func cellWithID(id: String, _ indexPath: NSIndexPath) -> UITableViewCell {
         return self.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath) as! UITableViewCell
    }
}

extension UICollectionView {
  func cellWithID(id: String, _ indexPath: NSIndexPath) -> UICollectionViewCell {
    return self.dequeueReusableCellWithReuseIdentifier(id, forIndexPath: indexPath) as! UICollectionViewCell
  }
}

extension NSObject {
    func postNotification(name: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
    }
    
    func registerForNotification(name: String, action: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: action, name: name, object: nil)
    }
}

extension String {
    func replace(a: String, _ b: String) -> String {
        var option = NSStringCompareOptions.LiteralSearch
        return self.stringByReplacingOccurrencesOfString(a, withString: b, options:option , range: nil)
    }
    
    func delete(a: String) -> String {
        var option = NSStringCompareOptions.LiteralSearch
        return self.stringByReplacingOccurrencesOfString(a, withString: "", options:option , range: nil)
    }
    
    mutating func captialName() -> String {
        if count(self) < 1 { return "" }
        var index = self.startIndex
        self.replaceRange(index...index, with: String(self[index]).capitalizedString)
        return self
    }
}

extension Array {
    mutating func appendArr(arr: Array<T>) {
        for element in arr {
            self.append(element)
        }
    }
}

extension NSDate {
    func iso8601String() -> String {
        var df = NSDateFormatter()
        var enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.locale = enUSPosixLocale
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZZZZZ"
        println(df.stringFromDate(self))
        return df.stringFromDate(self)
    }
    
    class func dateFromIso8601String(str: String) -> NSDate? {
        var df = NSDateFormatter()
        var enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZZZZZ"
        df.locale = enUSPosixLocale
        if let date = df.dateFromString(str) {
            return date
        } else {
            return nil
        }
    }
    
    func dateString() -> String {
        var df = NSDateFormatter()
        df.dateFormat = "EE MMMM d, YYYY"
        return df.stringFromDate(self)
    }
    
    func timeString() -> String {
        var df = NSDateFormatter()
        df.dateFormat = "hh:mma"
        return df.stringFromDate(self).lowercaseString
    }
}


@IBDesignable
class PaddingTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}

typealias LoadingView = SVProgressHUD
typealias ZGNavVC = ZGNavigationBarTitleViewController



