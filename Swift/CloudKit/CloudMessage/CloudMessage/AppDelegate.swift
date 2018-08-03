//
//  AppDelegate.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol RecordChangeDelegate {
    func recordDidChangeAtZone(_ zoneID: CKRecordZoneID, record: CKRecord)
    func zoneDeleted(_ zoneID: CKRecordZoneID)
    func recordDeleted(_ recordID: CKRecordID)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var delegates: [RecordChangeDelegate] = [RecordChangeDelegate]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Register for silent pushes
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Whenever there's a remote notification, this gets called
        
        let dictionary = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dictionary)
        
        
        if notification.subscriptionID == "cloudkit-conversation-changes" {
            // Fetch shared changes
            fetchSharedChanges {
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    }
    
    func fetchSharedChanges(_ callback: @escaping () -> Void) {
        let changeTokenKey = "changeToken"
        let changesOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: UserDefaults.standard.object(forKey: changeTokenKey) as? CKServerChangeToken) // Enter change token
        
        var zoneIDs = [CKRecordZoneID]()
        
        changesOperation.recordZoneWithIDChangedBlock = { (zoneID) in
            // Collect zone IDs
            zoneIDs.append(zoneID)
        }
        
        changesOperation.recordZoneWithIDWasDeletedBlock = { (zoneID) in
            // Delete cache of record zone (I should be caching on a per zone basis)
            for delegate in self.delegates {
                delegate.zoneDeleted(zoneID)
            }
        }
        
        changesOperation.changeTokenUpdatedBlock = { (changeToken) in
            UserDefaults.standard.set(changeToken, forKey: changeTokenKey)
        }
        
        changesOperation.fetchDatabaseChangesCompletionBlock = { (newToken, more, error) in
            // error handling here
            
            UserDefaults.standard.set(newToken, forKey: changeTokenKey)
            self.fetchZoneChanges(in: zoneIDs, callback)
        }
        
        CKContainer.default().publicCloudDatabase.add(changesOperation)
    }
    
    func fetchZoneChanges(in zoneIDs: [CKRecordZoneID], _ callback: @escaping () -> Void) {
        let changesOperation = CKFetchRecordZoneChangesOperation()
        changesOperation.recordZoneIDs = zoneIDs
        
        changesOperation.recordChangedBlock = { (record) in
            // update the local cache with the changed record (delegate call)
            for delegate in self.delegates {
                delegate.recordDidChangeAtZone(record.recordID.zoneID, record: record)
            }
        }
        
        changesOperation.recordWithIDWasDeletedBlock = { (recordID, recordType) in
            // delete the specific record from the local cache
            for delegate in self.delegates {
                delegate.recordDeleted(recordID)
            }
        }
        
        changesOperation.recordZoneChangeTokensUpdatedBlock = { (zoneID, changeToken, data) in
            // cache change token
            UserDefaults.standard.set(changeToken, forKey: "changeToken")
        }
        
        changesOperation.recordZoneFetchCompletionBlock = { (zoneID, changeToken, clientChangeTokenData, moreComing, error) in
            // handle error
            
            // Check if the clientChangeTokenData is the same as the last token I provided - if it isn't the server didn't recieve the last update
            // cache change token
            UserDefaults.standard.set(changeToken, forKey: "changeToken")
            
            callback()
        }
        
        CKContainer.default().publicCloudDatabase.add(changesOperation)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("application did register for remote notifications with device token")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("application FAILED to register for remote notifications with device token")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        fetchSharedChanges { }// Do something maybe
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

