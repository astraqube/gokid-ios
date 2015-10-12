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
        setImageWithTransformer(urlStr, imageView: imageView, transformer: nil)
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
    
    
    class ImageFetchOperation : NSOperation {
        var url : String
        var image : UIImage?
        
        init(imageUrl: String){
            url = imageUrl
        }
        
        var _executing = false
        var _finished = false
        
        @objc override var executing : Bool {
            get { return _executing }
            set {
                self.willChangeValueForKey("isExecuting")
                self._executing = false
                self.didChangeValueForKey("isExecuting")
            }
        }
        @objc override var finished : Bool {
            get { return _finished }
            set {
                self.willChangeValueForKey("isFinished")
                self._finished = true
                self.didChangeValueForKey("isFinished")
            }
        }
        override var asynchronous : Bool { return true }
        
        override func start() {
            self.executing = true
            ImageManager.sharedInstance.getImageAtURL(url, callback: { (image, error) -> () in
                self.image = image
                if let error = error { println("failed ImageFetchOperation of url \(self.url) with error \(error)") }
                self.finished = true
                self.executing = false
            })
        }
    }
    
    func getImagesAtURLs(urls: [String], callback: ((imagesByURL: [String : UIImage]) -> ())) {
        var dict = [String : UIImage]()
        if urls.count == 0 { callback(imagesByURL: dict); return }
        
        var operations = [ImageFetchOperation]()
        
        var onCompletionOp = NSBlockOperation { () -> Void in
            for operation in operations{
                if let image = operation.image {
                    dict[operation.url] = image
                }
            }
            callback(imagesByURL: dict)
        }
        for url in urls {
            let imageOp = ImageFetchOperation(imageUrl: url)
            onCompletionOp.addDependency(imageOp)
            operations.append(imageOp)
        }
        NSOperationQueue.mainQueue().addOperations(operations, waitUntilFinished: false)
        NSOperationQueue.mainQueue().addOperation(onCompletionOp)
    }
    
    ///recrursive function taking a url and returning a uiimage
    func getImageAtURL(urlStr: String, callback : ((image: UIImage?, error: String?)->())){
        if let image = memCached[urlStr] {
            callback(image: image, error: nil)
        } else if findDiskCachedImageByURL(urlStr, { (img: UIImage?) in
            if let image = img {
                self.memCached[urlStr] = image
            } else {
                self.removeDiskCacheForURL(urlStr) //bad cache, but can still recurse
            }
            callback(image: img, error: nil)
        }) {
            return
        } else if let url = NSURL(string: urlStr){
            var session = NSURLSession.sharedSession()
            session.dataTaskWithURL(url) { (data, response, error) in
                if let image = UIImage(data: data) {
                    self.memCached[urlStr] = image
                    self.diskCacheImageWithURLStr(image, urlStr)
                    callback(image: image, error: nil)
                } else {
                    callback(image: nil, error: "couldn't download image")
                }}.resume()
        } else {
            callback(image: nil, error: "malformed image url")
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
            var picture: UIImage!

            // image redraws to its intended orientation
            if !(img.imageOrientation == .Up || img.imageOrientation == .UpMirrored) {
                let imgsize = img.size
                UIGraphicsBeginImageContext(imgsize)
                img.drawInRect(CGRectMake(0.0, 0.0, imgsize.width, imgsize.height))
                picture = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            } else {
                picture = img
            }

            var data = UIImagePNGRepresentation(picture)
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
        //var arr = urlStr.componentsSeparatedByString("/")
        //var id  = arr.last
        //return id!
        return String(urlStr.hash)
    }
    
    func filePathForImgID(id: String) -> String {
        println(imageDirPath + id)
        return imageDirPath + id
    }
}

