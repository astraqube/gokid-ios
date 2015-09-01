//
//  HelperFunction.swift
//  WeRead
//
//  Created by Bingwen Fu on 7/7/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

class HelperFunction: NSObject { }

func debounce( delay:NSTimeInterval, #queue:dispatch_queue_t, action: (()->()) ) -> ()->() {

    var lastFireTime:dispatch_time_t = 0
    let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))

    return {
        lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                dispatchDelay
            ),
            queue) {
                let now = dispatch_time(DISPATCH_TIME_NOW,0)
                let when = dispatch_time(lastFireTime, dispatchDelay)
                if now >= when {
                    action()
                }
        }
    }
}

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
    var map = DataManager.sharedInstance.sbViewControllerList()
    for (k, v) in map {
        if v[ID] != nil {
            return vcWithID(ID, k)
        }
    }
    assertionFailure("View Controller doesn't exsit")
    return UIViewController()
}

func vcWithID(ID: String, StoryBoard: String) -> UIViewController {
    var sb = UIStoryboard(name: StoryBoard, bundle: NSBundle.mainBundle())
    var vc = sb.instantiateViewControllerWithIdentifier(ID) as! UIViewController
    return vc
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

    func removeNotification(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    func removeNotification(observer: AnyObject, name: String) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: nil)
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
    
    func firstCharacter() ->String {
        if count(self) > 0 {
            return String(self[self.startIndex])
        } else {
            return ""
        }
    }

    func truncateToCharacters(num: Int) -> String {
        let index: String.Index = advance(self.startIndex, num)
        return self.substringToIndex(index)
    }

    func twoLetterAcronym() -> String {
        var acronym : String!
        if count(self) >= 2 {
            let index: String.Index = advance(self.startIndex, 2)
            acronym = self.substringToIndex(index)
        } else {
            acronym = self
        }

        var words = self.componentsSeparatedByString(" ")
        words = words.filter { (word: String) -> Bool in
            return word != ""
        }
        if words.count > 1 {
            acronym = words[0].firstCharacter() + words[1].firstCharacter()
        }

        return acronym
    }

    mutating func captialName() -> String {
        if count(self) < 1 { return "" }
        var index = self.startIndex
        self.replaceRange(index...index, with: String(self[index]).capitalizedString)
        return self
    }
    
    static func fromData(data: NSData) -> String {
        return NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    }
}

extension Array {
    mutating func appendArr(arr: Array<T>) {
        for element in arr {
            self.append(element)
        }
    }
}
/* DEPRECATED
extension SwiftAddressBookPerson {
 
    func firstNameStr() -> String {
        if let name = self.firstName {
            return name
        }
        return "null"
    }
    
    func fullName() -> String {
        var firstName = ""
        var lastName = ""
        if self.firstName != nil { firstName = self.firstName! }
        if self.lastName != nil { lastName = self.lastName! }
        var fullName = firstName + " " + lastName
        return fullName
    }
    
    func proccessedPhoneNum() -> String {
        if let number = self.__RawPhoneNumbe() {
            var final = number.delete(" ").delete("(").delete(")").delete("-")
            return final
        }
        return ""
    }
    
    func rawPhoneNumber() ->String {
        if let number = self.__RawPhoneNumbe() {
            return number
        }
        return "No number found for this person"
    }
    
    func __RawPhoneNumbe() -> String? {
        if let phoneNumbers = self.phoneNumbers?.map({$0.value}) {
            if phoneNumbers.count > 0 {
                return phoneNumbers[0]
            }
        }
        return nil
    }
}
*/

@IBDesignable
class PaddingTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }

    @IBInspectable var borderColor : UIColor = UIColor.blackColor() {
        didSet {
            layer.borderColor = borderColor.CGColor;
        }
    }

    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
}

typealias LoadingView = SVProgressHUD
typealias ZGNavVC = ZGNavigationBarTitleViewController



