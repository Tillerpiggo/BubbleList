//
//  AppDelegate.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/23/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications
import Reachability

protocol NotificationDelegate {
    func fetchChanges(completion: @escaping (Bool) -> Void)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var cloudController = CloudController()
    lazy var coreDataController = { () -> CoreDataController in
        let coreDataStack = CoreDataStack(modelName: "MagnetHomeworkApp")
        let coreDataController = CoreDataController(coreDataStack: coreDataStack)
        return coreDataController
    }()
    
    var notificationDelegate: NotificationDelegate?
    
    var classTableViewControllerReference: ClassTableViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //UIApplication.shared.statusBarView?.backgroundColor = .primaryColor
        
        //application.applicationIconBadgeNumber = 0
        
        if let tabBarController = window?.rootViewController as? UITabBarController,
            let navigationController = tabBarController.viewControllers?.first as? UINavigationController,
            let classTableViewController = navigationController.topViewController as? ClassTableViewController,
            let toDoNavigationController = tabBarController.viewControllers?.last as? UINavigationController,
            let toDoTableViewController = toDoNavigationController.topViewController as? ToDoTableViewController {
            
            toDoTableViewController.cloudController = cloudController
            toDoTableViewController.coreDataController = coreDataController
            
            // Dependency inject the CoreData/CloudKit Objects
            classTableViewController.cloudController = cloudController
            classTableViewController.coreDataController = coreDataController
            
            tabBarController.tabBar.tintColor = .primaryColor
//            tabBarController.tabBar.barTintColor = .tabBarTintColor
            //tabBarController.tabBar.addDropShadow(color: .black, opacity: 0.2, radius: 2)
            
            classTableViewControllerReference = classTableViewController
        }
        
        // Try to register for notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
                DispatchQueue.main.sync() { application.registerForRemoteNotifications() }
            }
        })
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping(UIBackgroundFetchResult) -> Void) {
        
        print("RECIEVED NOTIFICATION!")

        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        
        var didReceiveData: Bool = false
        
        if notification.subscriptionID == "cloudkit-privateClass-changes2" || notification.subscriptionID == "cloudkit-privateAssignment-changes2" || notification.subscriptionID == "cloudkit-sharedDatabase-changes2" || notification.subscriptionID == "cloudkit-privateToDo-changes2" {
            notificationDelegate?.fetchChanges() { (didFetchRecords) in
                if !didReceiveData {
                    completionHandler(.noData)
                    didReceiveData = true
                }
            }
        }
        if !didReceiveData {
            completionHandler(.noData)
        }
    }
    
    // MARK: - CloudKit Sharing
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        cloudController.acceptShare(withShareMetadata: cloudKitShareMetadata) {
            self.notificationDelegate?.fetchChanges() { _ in
                // TODO: Send the user to tyhe approriate location (the new class)
                DispatchQueue.main.async {
                    if let navigationController = self.window?.rootViewController as? UINavigationController,
                        let classTableViewController = navigationController.topViewController as? ClassTableViewController {
                        // classTableViewController.openClass(withRecordID: cloudKitShareMetadata.rootRecordID)
                        print("Tried to open class (not currently implemented)")
                    }
                    
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Did register for remote notifications with device token")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Did fail to register for remote notifications with device token")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataController.save()
        
        // TODO: Save Cloud Stuff (persistent)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.notificationDelegate?.fetchChanges() { _ in }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataController.save()
        
        // TODO: Save Cloud Stuff (persistent)
    }
}

