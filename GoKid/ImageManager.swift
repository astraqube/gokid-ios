//
//  ImageManager.swift
//  WeRead
//
//  Created by Bingwen Fu on 7/19/14.
//  Copyright (c) 2014 Bingwen. All rights reserved.
//

import UIKit

class ImageManager: NSObject {
    
    // cache map
    var memCached = Dictionary<String, UIImage>()
    var diskCached = Dictionary<String, String>()
    
    // key   - urlString of a image
    // value - a list of imageView that is waiting for the image
    var waitingPool = Dictionary<String, [UIImageView]>()
    
    // key   - imageView
    // value - the latest wanted url of image of the imageView
    var latestWantedURL = Dictionary<UIImageView, String>()
    
    // image folder, sotre disk cached image
    let imageDirPath = NSHomeDirectory() + "/Documents/Images/"
    
    typealias ImageTransformer = ((UIImage) -> UIImage)
    typealias IMCompletion = ((UIImage?) -> Void)
    
    // MARK: Singleton
    class var sharedInstance : ImageManager {
        struct Static {
            static let instance : ImageManager = ImageManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        getDiscCachedMap()
    }
    
    // MARK: Transformer method
    func cropTransformer(image: UIImage) -> UIImage {
        
        var sw: CGFloat = 100
        var sh: CGFloat = 100
        var iw: CGFloat = image.size.width
        var ih: CGFloat = image.size.height
        
        //Create the bitmap graphics context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sw, sh), false, 0.0);
        var context = UIGraphicsGetCurrentContext();
        
        //Get the width and heights
        var rectWidth = sw;
        var rectHeight = sh;
        
        //Calculate the scale factor
        var scaleFactorX = rectWidth/iw;
        var scaleFactorY = rectHeight/ih;
        
        //Calculate the centre of the circle
        var imageCentreX = rectWidth/2;
        var imageCentreY = rectHeight/2;
        
        // Create and CLIP to a CIRCULAR Path
        // (This could be replaced with any closed path if you want a different shaped clip)
        var radius = rectWidth/2;
        CGContextBeginPath(context);
        CGContextAddArc(context, imageCentreX, imageCentreY, radius, 0, CGFloat(2*M_PI), 0);
        CGContextClosePath(context);
        CGContextClip(context);
        
        //Set the SCALE factor for the graphics context
        //All future draw calls will be scaled by this factor
        CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
        
        // Draw the IMAGE
        var myRect = CGRectMake(0, 0, iw, ih);
        image.drawInRect(myRect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    func standerTransformer(image: UIImage) -> UIImage {
        var iw: CGFloat = image.size.width
        var ih: CGFloat = image.size.height
        var cw: CGFloat = 320 * 2
        var ch: CGFloat = 160 * 2
        var canvas_size = CGSizeMake(cw, ch)
        
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        var dw: CGFloat = 100
        var dh: CGFloat = 100
        
        if iw/ih > cw/ch {
            dh = ch
            dw = dh * (iw/ih)
            dx = -(dw - cw)/2
            dy = 0
        } else {
            dw = cw
            dh = dw * (ih/iw)
            dy = -(dh - ch)/2
            dx = 0
        }
        
        var rect = CGRectMake(dx, dy, dw, dh)
        UIGraphicsBeginImageContext(canvas_size)
        image.drawInRect(rect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: Interface for this class
    func setImageToView(imageView: UIImageView, urlStr: String) {
        setImageWithTransformer(urlStr, imageView: imageView, transformer: standerTransformer)
    }
    
    func setImageToViewWithCrop(imageView: UIImageView, urlStr: String) {
        setImageWithTransformer(urlStr, imageView: imageView, transformer: cropTransformer)
    }
    
    func setImageWithTransformer(urlStr: String, imageView: UIImageView, transformer: ImageTransformer?) {
        
        // update imageView:URL map
        latestWantedURL[imageView] = urlStr
        
        // *******************************
        // try to find mem cached image
        // *******************************
        if let image = memCached[urlStr] {
            imageView.image = image
            return
        }
        
        // image is being downloaded
        if waitingPool[urlStr] != nil {
            waitingPool[urlStr]!.append(imageView)
            return
        }
        
        waitingPool[urlStr] = [imageView]
        // *******************************
        // try to find disk cached image
        // *******************************
        var result = findDiskCachedImageByURL(urlStr) { (img: UIImage?) in
            if let image = img {
                // println("get disk cached image \(urlStr)")
                self.memCached[urlStr] = image
                self.setAllWatingImageView(urlStr, image)
            }
        }
        if result { return }
        
        // *******************************
        // Download image from sever
        // *******************************
        // println("prepare to download \(urlStr)")
        downloadImageByURLStr(urlStr) { (img: UIImage?) in
            if let image = img {
                var cropedImage = image
                if let crop = transformer {
                    cropedImage = crop(image)
                }
                self.memCached[urlStr] = cropedImage
                self.diskCacheImageWithURLStr(cropedImage, urlStr)
                self.setAllWatingImageView(urlStr, cropedImage)
            }
        }
    }
    
    // set the image to all the imageView that
    // is waiting for this image
    func setAllWatingImageView(urlStr: String, _ image: UIImage) {
        let imageViewCandidate = self.waitingPool[urlStr] as [UIImageView]!
        for imgView in imageViewCandidate {
            if self.latestWantedURL[imgView] == urlStr {
                onMainThread() {
                    imgView.image = image
                }
            }
        }
        self.waitingPool[urlStr] = nil
    }
    
    // MARK: Image Fecthing Method
    func findDiskCachedImageByURL(urlStr: String, _ completion: IMCompletion) -> Bool {
        // try to find the image on disk
        if urlExistOnDisk(urlStr) {
            onGlobalThread() {
                var id = self.imgIDForURL(urlStr)
                var path = self.filePathForImgID(id)
                var error: NSError?
                var data  = NSData(contentsOfFile: path, options: .DataReadingUncached, error: &error)
                var image = UIImage(data: data!)
                completion(image)
            }
            return true
        }
        return false
    }
    
    func downloadImageByURLStr(urlStr: String, _ completion: IMCompletion) {
        // check the url is valid
        var url = NSURL(string: urlStr)
        if url == nil {
            println(__FUNCTION__ + " url not valid: " + urlStr)
            return
        }
        // download
        var session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!) { (data, response, error) in
            if error != nil { println(error); return }
            if let image = UIImage(data: data) {
                println("downloaded image \(urlStr)")
                completion(image)
            } else {
                println("Invalid image url \(urlStr)")
                return
            }
            }.resume()
    }
    
    func diskCacheImageWithURLStr(img: UIImage, _ urlStr: String) {
        // cache it to disk
        onGlobalThread() {
            var id = self.imgIDForURL(urlStr)
            var path = self.imageDirPath + id
            var data = UIImagePNGRepresentation(img)
            data.writeToFile(path, atomically: true)
            self.diskCached[id] = id
        }
    }
    
    func removeDiskCacheForURL(urlStr: String) {
        if urlStr == "" { return }
        var fileManager = NSFileManager.defaultManager()
        var id = self.imgIDForURL(urlStr)
        var path = self.imageDirPath + id
        diskCached[id] = nil
        memCached[urlStr] = nil
        if fileManager.fileExistsAtPath(path) {
            fileManager.removeItemAtPath(path, error: nil)
        }
    }
    
    // MARK: Initialize disk cached map
    func getDiscCachedMap() {
        var fileManager = NSFileManager.defaultManager()
        // if Documents/Image doesn't exsits, we need create one
        if fileManager.fileExistsAtPath(imageDirPath) == false {
            var error: NSError?
            fileManager.createDirectoryAtPath(imageDirPath,
                withIntermediateDirectories: true, attributes: nil, error: &error)
            if error != nil {
                println(error)
            }
        }
        // after making sure Documents/Image exsist we construct diskCachedMap
        var error: NSError?
        var allImage = fileManager.contentsOfDirectoryAtPath(imageDirPath, error: &error) as! [String]
        for imgID in allImage {
            diskCached[imgID] = imgID
        }
    }
    
    // MARK: Helper method
    func urlExistOnDisk(urlStr: String) -> Bool {
        var id = imgIDForURL(urlStr)
        return (diskCached[id] != nil)
    }
    
    func imgIDForURL(urlStr: String) -> String {
        var arr = urlStr.componentsSeparatedByString("/")
        var id  = arr.last
        return id!
    }
    
    func filePathForImgID(id: String) -> String {
        return imageDirPath + id
    }
}

