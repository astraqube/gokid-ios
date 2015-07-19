//
//  CalendarUserImageView.swift
//  GoKid
//
//  Created by Alexander Hoekje List on 7/9/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit

@IBDesignable
class CalendarUserImageView: UIView {
    lazy var imageView = UIImageView()
    ///Set this guy to display the image
    @IBInspectable var image : UIImage? {
        didSet{
            imageView.image = self.image
            update()
        }
    }
    lazy var nameLabel = UILabel()
    ///Set this guy to have letters made when no image
    @IBInspectable var nameString : NSString = "?" {
        didSet{
            var abbreviation : String?
            if self.nameString.length >= 2 {
                abbreviation = self.nameString.substringToIndex(2)
            }else{
                abbreviation = self.nameString.substringToIndex(self.nameString.length)
            }
            var words = self.nameString.componentsSeparatedByString(" ")
            if words.count > 1 {
                abbreviation = words[0].substringToIndex(1) + words[1].substringToIndex(1)
            }
            nameLabel.text = abbreviation
        }
    }
    
    @IBInspectable var centerImage : Bool = false {
        didSet{
            if self.centerImage {
                imageView.contentMode = UIViewContentMode.Center
            } else {
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
            }
        }
    }
    
    @IBInspectable var noImageColor : UIColor = UIColor.whiteColor() {
        didSet {
            imageView.backgroundColor = noImageColor
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            if cornerRadius > 0 {
                imageView.layer.cornerRadius = cornerRadius + 1.0
                imageView.layer.masksToBounds = true
            }
        }
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.borderWidth = CGFloat(4)
        self.borderColor = UIColor(red: 230.0/255.0, green: 246.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        
        self.addSubview(imageView)
        imageView.frame = self.bounds

        nameLabel.textAlignment = .Center
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont(name: "Raleway-Regular", size: 16)
        self.addSubview(nameLabel)
        nameLabel.frame = self.bounds
        update()
    }
    
    func update() {
        if image == nil{
            nameLabel.hidden = false
        } else {
            nameLabel.hidden = true
        }
    }
}
