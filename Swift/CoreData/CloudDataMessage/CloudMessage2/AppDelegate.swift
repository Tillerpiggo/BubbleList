//
//  AppDelegate.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol NotificationDelegate {
    func fetchChanges(completion: @escaping (Bool) -> Void)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataController = { () -> CoreDataController in
        let coreDataStack = CoreDataStack(modelName: "CloudMessage")
        let coreDataController = CoreDataController(coreDataStack: coreDataStack)
        return coreDataController
    }()
    
    var notificationDelegates: [NotificationDelegate] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let navigationController = window?.rootViewController as? UINavigationController,
            let conversationTableViewController = navigationController.topViewController as? ConversationTableViewController {
            
            // Dependency inject the CoreData/CloudKit Objects
            conversationTableViewController.cloudController = CloudController()
            conversationTableViewController.coreDataController = coreDataController
        }
        
        // Register for silent push notifications from CloudKit
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping(UIBackgroundFetchResult) -> Void) {
        print("Received notification!")
        
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        var didRecieveData: Bool = false
        if notification.subscriptionID == "cloudkit-Conversation-changes" || notification.subscriptionID == "cloudkit-Message-changes" {
            for notificationDelegate in notificationDelegates {
                notificationDelegate.fetchChanges() { (didFetchRecords) in
                    if !didRecieveData && didFetchRecords {
                        completionHandler(.newData)
                        didRecieveData = true
                    }
                }
            }
        }
        if !didRecieveData {
            completionHandler(.noData)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataController.save()
        
        // TODO: Save Cloud Stuff
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataController.save()
        
        // TODO: Save Cloud Stuff
    }


}

