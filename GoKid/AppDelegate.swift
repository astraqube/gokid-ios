//
//  AppDelegate.swift
//  GoKid
//
//  Created by Bingwen Fu on 5/31/15.
//  Copyright (c) 2015 GoKid. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

let kGKPickup = "Arrive at "
let kGKDropoff = "Depart from "
let kGKInvitationsKey = "kGKInvitationsKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        var size = self.window!.frame.size
        var um = UserManager.sharedInstance
        um.windowH = size.height
        um.windowW = size.width
        
        // register notification
        var settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        // for google places api
        GMSServices.provideAPIKey("AIzaSyBHRdk9v9JyWbzLclg9tTET17eWeYXk5MU")
        
        // for facebook login
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginButton.self
        
        // for fabric
        Fabric.with([Crashlytics()])

        // Default colors
        self.window?.tintColor = ColorManager.sharedInstance.color67C18B
        self.window?.backgroundColor = ColorManager.sharedInstance.colorEBF7EB

        if launchOptions != nil {
            if let remoteNotification = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                self.application(application, didReceiveRemoteNotification: remoteNotification)
            }
        }

        return true
    }
    
    // MARK: Notification Method
    // --------------------------------------------------------------------------------------------
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        println("didRegisterUserNotificationSettings")
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("fail to register remote notification")
        NSLog(error.localizedDescription)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("success register for remote notification")
        var str = NSMutableString()
        var ptr = UnsafePointer<CChar>(deviceToken.bytes)
        for var i = 0; i < 32; i++ {
            str.appendFormat("%02.2hhX", ptr[i])
        }

        // dropoff for deviceToken
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(String(str), forKey: "deviceToken")
    }
    
    // MARK: Facebook Deep Link
    // --------------------------------------------------------------------------------------------
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

        if url.scheme == "gokid" && url.host == "invited" {
            // dropoff for when `gotInvited` observer does not exist
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(url.path!.delete("/"), forKey: "gotInvited")

            // post when `gotInvited` observer exists
            prefs.postNotification("gotInvited")
        }

        // for facebook login
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()

        if UserManager.sharedInstance.userLoggedIn {
            InvitationModel.checkInvitations()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if UserManager.sharedInstance.userLoggedIn {
            InvitationModel.checkInvitations()

            if let inviteCode = userInfo["code"] as? String {
                // dropoff for when `gotInvited`
                let prefs = NSUserDefaults.standardUserDefaults()
                prefs.setValue(inviteCode, forKey: "gotInvited")

                if application.applicationState == .Active {
                    prefs.postNotification("gotInvitedNotify")
                } else {
                    prefs.postNotification("gotInvited")
                }
            }
        }
    }
}

