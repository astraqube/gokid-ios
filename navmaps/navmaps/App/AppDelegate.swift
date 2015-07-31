//
//  AppDelegate.swift
//  navmaps
//
//  Created by Alexander Hoekje List on 7/3/15.
//  Copyright (c) 2015 Gigster Inc. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var nav = window!.rootViewController as! UINavigationController
        var vc = nav.topViewController as! DetailMapVC
        var navigation = Navigation()
        var pickups : [Stop] = [
            Stop(coordinate: CLLocationCoordinate2DMake(37.4528, -122.1833), name: "Menlo's House", address: "123 Fake St 91210", phoneNumber: "18002831337", stopID: "1", thumbnailImage: UIImage(named: "test_userImage")),
            Stop(coordinate: CLLocationCoordinate2DMake(37.4528, -122.1133), name: "Righty's House", address: "333 Fake St 91210", phoneNumber: "18002831337", stopID: "4", thumbnailImage: UIImage(named: "test_userImage")),
            Stop(coordinate: CLLocationCoordinate2DMake(37.4598, -122.1893), name: "Kid's House", address: "4821 Fake Ln 91210", phoneNumber: "18002831437", stopID: "2", thumbnailImage: nil),
            Stop(coordinate: CLLocationCoordinate2DMake(37.4608, -122.2093), name: "Another Kid's House", address: "8912 Big Fake Ave 91211", phoneNumber: "18002831537", stopID: "3", thumbnailImage: nil)
        ]
        
        var dropoffs : [Stop] = [
            Stop(coordinate: CLLocationCoordinate2DMake(37.783333, -122.416667), name: "Soccer Club", address: "4 Soccer Way 92118", phoneNumber: nil, stopID: "10", thumbnailImage: nil)
        ]
        navigation.setup(pickups, dropoffs:dropoffs);
        vc.navigation = navigation
        vc.metadata = MapMetadata(name: "Soccer", thumbnailImage: UIImage(named: "test_userImage"), date: NSDate(timeIntervalSinceNow: 0), canNavigate: true, id: 0, type: .Dropoff)
        return true
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

