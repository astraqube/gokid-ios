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
    var image : UIImage? {
        didSet{
            imageView.image = self.image
            if self.image == nil {
                nameLabel.hidden = false
            } else {
                nameLabel.hidden = true
            }
        }
    }
    lazy var nameLabel = UILabel()
    ///Set this guy to have letters made when no image
    var nameString : NSString = "?" {
        didSet{
            nameLabel.text = (self.nameString as! String).twoLetterAcronym()
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
    }
    
    func setAvatar(fullName: String!, imageURL: String!) {
        if imageURL != "" && imageURL.rangeOfString("thumb_default") == nil {
            ImageManager.sharedInstance.setImageToViewWithCrop(imageView, urlStr: imageURL)
            nameLabel.hidden = true
        } else {
            nameString = fullName
            nameLabel.hidden = false
        }
    }
}
