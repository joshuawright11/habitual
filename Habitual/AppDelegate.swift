//
//  AppDelegate.swift
//  Habitual
//
//  Created by Josh Wright on 6/12/15.
//  Copyright (c) 2015 Josh Wright. All rights reserved.
//

import UIKit
import CoreData
import Parse
import Fabric
import Crashlytics
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - App Lifecycle methods
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Crashlytics setup
        Fabric.with([Crashlytics.self])
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // Parse setup
        Parse.setApplicationId(kParseApplicationId, clientKey: kParseClientKey)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if let _ = PFUser.currentUser() {
            PFInstallation.currentInstallation().saveEventually()
        }
        
        PFUser.currentUser()?.fetchInBackground()
        
        doDesign()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    /// Reschedule local notifications every time the app is closed
    func applicationDidEnterBackground(application: UIApplication) {scheduleLocalNotifications()}

    func applicationWillEnterForeground(application: UIApplication) {}

    /// Clear the badge number of the app every time the app is opened
    func applicationDidBecomeActive(application: UIApplication) {
        Utilities.clearBadgeNumber()
        FBSDKAppEvents.activateApp()
    }

    /// Save the Core Data stack every time the app is closed
    func applicationWillTerminate(application: UIApplication) {self.saveContext()}
    
    // MARK: - Design methods
    
    /// Sets the global fonts and colors
    func doDesign() {
        
        // Table View
        UITableView.appearance().backgroundColor = Colors.background
        UITableView.appearance().separatorColor = UIColor.clearColor()
        
        
        // Table View Cells
        UITableViewCell.appearance().backgroundColor = Colors.background
        
        
        // Table View Header and Footer Label
        UILabel.my_appearanceWhenContainedIn(UITableViewHeaderFooterView.self).textColor = Colors.textSecondary
        UILabel.my_appearanceWhenContainedIn(UITableViewHeaderFooterView.self).font = Fonts.sectionHeaderBold
        
        // Navigation Bars
        UINavigationBar.appearance().barTintColor = Colors.barBackground
        UINavigationBar.appearance().tintColor = Colors.accent
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes =
            [NSForegroundColorAttributeName: Colors.textMain, NSFontAttributeName: Fonts.navTitle]
        
        // Navigation Bar Buttons
        UIBarButtonItem.appearance().tintColor = Colors.accent
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: Fonts.navButtons], forState: UIControlState.Normal)
        
        // Tab Bar
        UITabBar.appearance().barTintColor = Colors.barBackground
        UITabBar.appearance().tintColor = Colors.accent
        UITabBar.appearance().translucent = false
        
        // Tab Bar Buttons and Titles
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: Fonts.tabBarTitle],
            forState: .Normal)
    }
    
    // MARK: - Push methods
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NotificationHandler.handPush(application.applicationState, userInfo: userInfo)
    }
    
    // MARK: - Core Data methods
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("HabitualModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Habitual.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

