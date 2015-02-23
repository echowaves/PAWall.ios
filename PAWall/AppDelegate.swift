//
//  AppDelegate.swift
//  PAWall
//
//  Created by D on 1/11/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import UIKit


let PWHost = "http://pawall.com"
//var DEVICE_TOKEN:String = ""
var DEVICE_PHONE_NUMBER = ""
var DEVICE_UUID = ""
let APP_DELEGATE:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
let USER_DEFAULTS = NSUserDefaults.standardUserDefaults()


func roundMoney(number: Double) -> Double {
    let numberOfPlaces = 2.0
    let multiplier = pow(10.0, numberOfPlaces)
    return round(number * multiplier) / multiplier
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var myAlerts:[PFObject] = [PFObject]()
    var tabBarController:PAWallTabBarController?

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // setup Flurry
        // Flurry.startSession("") // replace flurryKey with your own key
        Flurry.setCrashReportingEnabled(true)  // records app crashing in Flurry
        Flurry.logEvent("Start Application")   // Example of even logging
        Flurry.setSessionReportsOnCloseEnabled(false)
        Flurry.setSessionReportsOnPauseEnabled(false)
        Flurry.setBackgroundSessionEnabled(true)
        
        //setup parse
        // Parse.setApplicationId("", clientKey: "")
        // parse prod
        // parse dev

        
        // Register for Push Notitications and/or Alerts
        let userNotificationTypes:UIUserNotificationType = (UIUserNotificationType.Alert |
            UIUserNotificationType.Badge |
            UIUserNotificationType.Sound)

        let settings:UIUserNotificationSettings  = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        //        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(settings)
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
                
//        BaseDataModel.clearStoredCredential()
        //generate and store UUID for device if necessey
        if let credentials = BaseDataModel.getStoredCredential() {
            NSLog("getting GUID from nsuserdefaults")
            DEVICE_PHONE_NUMBER = credentials.user!
            DEVICE_UUID = credentials.password!
        }
        if DEVICE_UUID == "" {
            NSLog("generating new UDID")
            let uuidString = NSUUID().UUIDString
//            var uuidRef:CFUUIDRef  = CFUUIDCreate(kCFAllocatorDefault)
//            var uuidString = CFUUIDCreateString(nil, uuidRef)
            NSLog("uuid: \(uuidString)")
            BaseDataModel.storeCredential(DEVICE_PHONE_NUMBER, uuid: uuidString)
            DEVICE_UUID = uuidString
        }
//        NSLog("UUID: \(DEVICE_UUID)")
        getAlerts()
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
    
    
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        DEVICE_TOKEN = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
//        NSLog("My token is^^^^^^^^^^^^^^^^^^^^^^^^^: \(deviceToken)")
//        
//        //        let credential:NSURLCredential = BaseDataModel.getStoredCredential()!
//        //
//        //        if credential.user != "" {
//        //            BaseDataModel.storeIosToken(credential.user!,
//        //                token: self.deviceToken,
//        //                success: { (waveName) -> () in
//        //                    NSLog("stored device token for: \(waveName)")
//        //                },
//        //                failure: { (errorMessage) -> () in
//        //                    NSLog("failed storing deviceToken \(errorMessage)")
//        //            })
//        //
//        //        }
//    }
//    
//    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        NSLog("Failed to get token, error^^^^^^^^^^^^^^^^^^^^^^^: \(error)")
//    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSLog("fetching in background");
        completionHandler(UIBackgroundFetchResult.NewData)
        
        getAlerts()
        
    }
    
    func getAlerts() -> Void{
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        var query = PFQuery(className:GALERT.CLASS_NAME)
        
        query.whereKey(GALERT.TARGET, equalTo: DEVICE_UUID) // all alerts geard towards me
        query.orderByDescending("updatedAt")
        
        // Limit what could be a lot of points.
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count) alerts in background")

                self.myAlerts = objects as [PFObject]
                var unreadCount = self.unreadAlertsCount()
                if  unreadCount > 0 {
                    var localNotification:UILocalNotification = UILocalNotification()
                    localNotification.alertAction = "Alerts"
                    localNotification.alertBody = "There are \(unreadCount) alerts."
                    localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    UIApplication.sharedApplication().applicationIconBadgeNumber = unreadCount
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
            } else {
                // Log details of the failure
                NSLog("Error retreiveing alerts in background: %@ %@", error, error.userInfo!)
            }
        })
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NSLog("received local notification")
        let unreadAlertsCount:Int = self.unreadAlertsCount()
        application.applicationIconBadgeNumber = unreadAlertsCount
        NSLog("tabBarController is nil:\(tabBarController == nil)")
        if tabBarController != nil {
            let tabArray = self.tabBarController?.tabBar.items as NSArray!
            let tabItem = tabArray.objectAtIndex(2) as UITabBarItem
            if  unreadAlertsCount > 0 {
                tabItem.badgeValue = "\(unreadAlertsCount)"
            } else {
                tabItem.badgeValue = nil
            }
        }
        
//        var alert = UIAlertView()
//        alert.title = "Alert"
//        alert.message = notification.alertBody
//        alert.addButtonWithTitle("Dismiss")
//        alert.show()
    }
    
    func unreadAlertsCount() -> Int {
        var counter = 0
        for alert in myAlerts {
            if(alertUnread(alert)) {
                counter++
            }
        }
        
        return counter
    }
    
    func alertUnread(alert:PFObject) -> Bool {
        var readAlerts:[String]? = USER_DEFAULTS.objectForKey("readAlerts") as [String]?
        if readAlerts == nil {
            readAlerts = [String]()
            USER_DEFAULTS.setObject(readAlerts, forKey: "readAlerts")
            USER_DEFAULTS.synchronize()
        }

        if !contains(readAlerts!, "\(alert.objectId!):\(alert.updatedAt!)") {
            if(alert[GALERT.ALERT_BODY]  as String != "Post created by me:" && alert[GALERT.ALERT_BODY]  as String != "I replied to a post:") {
                return true
            }
        }
        return false
    }
    
    func markAlertRead(alert:PFObject) -> Void {
//        alert.fetchIfNeeded()
        var readAlerts:[String]? = USER_DEFAULTS.objectForKey("readAlerts") as [String]?
            readAlerts?.append("\(alert.objectId!):\(alert.updatedAt!)")
        USER_DEFAULTS.setObject(readAlerts, forKey: "readAlerts")
        USER_DEFAULTS.synchronize()
        getAlerts()
    }
    
}

//http://stackoverflow.com/questions/16244969/how-to-tell-git-to-ignore-individual-lines-i-e-gitignore-for-specific-lines-of
//http://www.buildsucceeded.com/2014/swift-move-uitextfield-so-keyboard-does-not-hide-it-ios-8-xcode-6-swift/
//https://github.com/NatashaTheRobot/SeinfeldQuotes
//http://www.appcoda.com/self-sizing-cells/
//http://www.snip2code.com/Snippet/197992/Swift-Background-Fetch

