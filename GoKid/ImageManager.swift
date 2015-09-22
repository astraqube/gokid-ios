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
        
        let sw: CGFloat = 100
        let sh: CGFloat = 100
        let iw: CGFloat = image.size.width
        let ih: CGFloat = image.size.height
        
        //Create the bitmap graphics context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(sw, sh), false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        //Get the width and heights
        let rectWidth = sw;
        let rectHeight = sh;
        
        //Calculate the scale factor
        let scaleFactorX = rectWidth/iw;
        let scaleFactorY = rectHeight/ih;
        
        //Calculate the centre of the circle
        let imageCentreX = rectWidth/2;
        let imageCentreY = rectHeight/2;
        
        // Create and CLIP to a CIRCULAR Path
        // (This could be replaced with any closed path if you want a different shaped clip)
        let radius = rectWidth/2;
        CGContextBeginPath(context);
        CGContextAddArc(context, imageCentreX, imageCentreY, radius, 0, CGFloat(2*M_PI), 0);
        CGContextClosePath(context);
        CGContextClip(context);
        
        //Set the SCALE factor for the graphics context
        //All future draw calls will be scaled by this factor
        CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
        
        // Draw the IMAGE
        let myRect = CGRectMake(0, 0, iw, ih);
        image.drawInRect(myRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    func standerTransformer(image: UIImage) -> UIImage {
        let iw: CGFloat = image.size.width
        let ih: CGFloat = image.size.height
        let cw: CGFloat = 320 * 2
        let ch: CGFloat = 160 * 2
        let canvas_size = CGSizeMake(cw, ch)
        
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
        
        let rect = CGRectMake(dx, dy, dw, dh)
        UIGraphicsBeginImageContext(canvas_size)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
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
        let result = findDiskCachedImageByURL(urlStr) { (img: UIImage?) in
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
                if let error = error { print("failed ImageFetchOperation of url \(self.url) with error \(error)") }
                self.finished = true
                self.executing = false
            })
        }
    }
    
    func getImagesAtURLs(urls: [String], callback: ((imagesByURL: [String : UIImage]) -> ())) {
        var dict = [String : UIImage]()
        if urls.count == 0 { callback(imagesByURL: dict); return }
        
        var operations = [ImageFetchOperation]()
        
        let onCompletionOp = NSBlockOperation { () -> Void in
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
            }else {
                self.removeDiskCacheForURL(urlStr) //bad cache, but can still recurse
            }
            self.getImageAtURL(urlStr, callback: callback)
        }){
            return
        } else if let url = NSURL(string: urlStr){
            let session = NSURLSession.sharedSession()
            session.dataTaskWithURL(url) { (data, response, error) in
                if let image = UIImage(data: data!) {
                    self.memCached[urlStr] = image
                    self.diskCacheImageWithURLStr(image, urlStr)
                    self.getImageAtURL(urlStr, callback: callback)
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
                let id = self.imgIDForURL(urlStr)
                let path = self.filePathForImgID(id)
                var data: NSData?
                do {
                    data = try NSData(contentsOfFile: path, options: .DataReadingUncached)
                } catch _ as NSError {
                    data = nil
                } catch {
                    fatalError()
                }
                let image = UIImage(data: data!)
                completion(image)
            }
            return true
        }
        return false
    }
    
    func downloadImageByURLStr(urlStr: String, _ completion: IMCompletion) {
        // check the url is valid
        let url = NSURL(string: urlStr)
        if url == nil {
            print(__FUNCTION__ + " url not valid: " + urlStr)
            return
        }
        // download
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!) { (data, response, error) in
            if error != nil { print(error); return }
            if let image = UIImage(data: data!) {
                print("downloaded image \(urlStr)")
                completion(image)
            } else {
                print("Invalid image url \(urlStr)")
                return
            }
            }.resume()
    }
    
    func diskCacheImageWithURLStr(img: UIImage, _ urlStr: String) {
        // cache it to disk
        onGlobalThread() {
            let id = self.imgIDForURL(urlStr)
            let path = self.imageDirPath + id
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

            let data = UIImagePNGRepresentation(picture)
            data!.writeToFile(path, atomically: true)
            self.diskCached[id] = id
        }
    }
    
    func removeDiskCacheForURL(urlStr: String) {
        if urlStr == "" { return }
        let fileManager = NSFileManager.defaultManager()
        let id = self.imgIDForURL(urlStr)
        let path = self.imageDirPath + id
        diskCached[id] = nil
        memCached[urlStr] = nil
        if fileManager.fileExistsAtPath(path) {
            do {
                try fileManager.removeItemAtPath(path)
            } catch _ {
            }
        }
    }
    
    // MARK: Initialize disk cached map
    func getDiscCachedMap() {
        let fileManager = NSFileManager.defaultManager()
        // if Documents/Image doesn't exsits, we need create one
        if fileManager.fileExistsAtPath(imageDirPath) == false {
            var error: NSError?
            do {
                try fileManager.createDirectoryAtPath(imageDirPath,
                    withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            if error != nil {
                print(error)
            }
        }
        // after making sure Documents/Image exsist we construct diskCachedMap
        let allImage = (try! fileManager.contentsOfDirectoryAtPath(imageDirPath))
        for imgID in allImage {
            diskCached[imgID] = imgID
        }
    }
    
    // MARK: Helper method
    func urlExistOnDisk(urlStr: String) -> Bool {
        let id = imgIDForURL(urlStr)
        return (diskCached[id] != nil)
    }
    
    func imgIDForURL(urlStr: String) -> String {
        //var arr = urlStr.componentsSeparatedByString("/")
        //var id  = arr.last
        //return id!
        return String(urlStr.hash)
    }
    
    func filePathForImgID(id: String) -> String {
        print(imageDirPath + id)
        return imageDirPath + id
    }
}

