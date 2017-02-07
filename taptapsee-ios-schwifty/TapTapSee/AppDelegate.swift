//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  AppDelegate.swift
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CloudSightConnection.sharedInstance().consumerKey = CLOUDSIGHT_KEY
        CloudSightConnection.sharedInstance().consumerSecret = CLOUDSIGHT_SECRET
            // Set some defaults
        var defaults = UserDefaults.standard
        if defaults.object(forKey: DEFAULT_FOCUS_LOCK_SOUND_KEY) == nil {
            defaults.set(true, forKey: DEFAULT_FOCUS_LOCK_SOUND_KEY)
        }
        if defaults.object(forKey: DEFAULT_FLASH_KEY) == nil {
            defaults.set(true, forKey: DEFAULT_FLASH_KEY)
        }
        defaults.synchronize()
            // Load remote defaults, make sure cache is off
        var sharedCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        URLCache.setShared(sharedCache)
        // Setup initial window
        self.window = UIWindow(frame: UIScreen.main.bounds)
            // Setup main view controller
        var viewController = CameraViewController()
        // Set status bar
        if CFloat(UIDevice.current.systemVersion) >= 7 {
            application.statusBarStyle = UIStatusBarStyleLightContent
        }
            // Setup base navigation controller
        var navController = UINavigationController(rootViewController: viewController)
        navController.navigationBarHidden = true
        // Start root view controller
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // Remove unfinished queries from history list
        HistoryItemStore.shared().removeUnfinishedQueries()
        // Remove all from the query manager (connection state won't be consistent when reloaded anyway)
        TagQueryManager.shared.reset()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
import CloudSight