//
//  Cloud.swift
//  Magnet Homework App
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

enum DatabaseType: String {
    case `private` = "private"
    case shared = "shared"
}

// An object that allows you to save and fetch data from the Cloud

class CloudController {
    
    var privateDatabase = CKContainer.default().privateCloudDatabase
    var sharedDatabase = CKContainer.default().sharedCloudDatabase
    
    let zoneID = CKRecordZone.ID(zoneName: "MagnetHomeworkApp", ownerName: CKCurrentUserDefaultName)
    
    let operationQueue = OperationQueue.main
    
    var isOperationInProgress: Bool = false
    
    var createdCustomZone: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "createdCustomZone")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "createdCustomZone")
        }
    }
    
    var subscribedToChanges: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "subscribedToChanges")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "subscribedToChanges")
        }
    }
    
    var privateDatabaseChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "privateDatabaseChangeToken"),
                let changeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
                return changeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "privateDatabaseChangeToken")
        }
    }
    
    var sharedDatabaseChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "sharedDatabaseChangeToken"),
                let changeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
                return changeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "sharedDatabaseChangeToken")
        }
    }
    
    var privateZoneChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "privateZoneChangeToken"),
                let changeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) {
                return changeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "privateZoneChangeToken")
        }
    }
    
    var sharedZoneChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "sharedZoneChangeToken"),
                let changeToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data){
                return changeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "sharedZoneChangeToken")
        }
    }
    
    // Saves the given cloud up
    func save(_ cloudUploadables: [CloudUploadable], inDatabase databaseType: DatabaseType, recordChanged: @escaping (CKRecord) -> Void, willRetry: Bool = true, completion: @escaping (Error?) -> Void = { (error) in }) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        operation.savePolicy = .ifServerRecordUnchanged
        operation.isAtomic = true
        
        switch databaseType {
        case .private:
            operation.database = privateDatabase
        case .shared:
            operation.database = sharedDatabase
        }
        
        // Map conversations to records
        let recordsToSave = cloudUploadables.map() { $0.ckRecord }
        operation.recordsToSave = recordsToSave
        operation.qualityOfService = .userInitiated
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
            
            print("Records to save")
            
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .modifyRecords, affectedObjects: recordsToSave.map({ $0.recordID })) {
                completion(ckError)
                
                // Handle error
                switch ckError.code {
                case .serverRecordChanged: // Sometimes this gets recursively called, so I'm clearly not handling everything properly
                    // Overwrite the home record
                    guard let serverRecord = ckError.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord else { return }
                    if let oldObject = cloudUploadables.first(where: { $0.ckRecord.recordID == serverRecord.recordID }) {
                        oldObject.update(withRecord: serverRecord)
                    }
                case .zoneNotFound:
                    // TODO: Notify users that the conversation/class no longer exists.
                    print("Zone not found in CloudController.save(_:completion:) operation.")
                case .unknownItem:
                    // TODO: Notify users that the conversation/class no longer exists
                    print("Record not found in CloudController.save(_:completion:) operation. - this shouldn't happen, it should just append the record to the database.")
                case .batchRequestFailed:
                    // Note: probably doesn't work
                    guard let failedItems = ckError.userInfo[CKPartialErrorsByItemIDKey] as? NSDictionary else {
                        print("Could not retrieve failed items from a .batchRequestFailed error.")
                        return
                    }
                    
                    // Loop through all recordID/error pairs - find what caused the atomic error, and then deal with it
                    for (failedRecordID, failedError) in failedItems {
                        guard let failedRecordID = failedRecordID as? CKRecord.ID, let failedError = failedError as? Error else { return }
                        
                        if ErrorHandler.handleCloudKitError(failedError, operation: .modifyRecords, affectedObjects: [failedRecordID]) != nil {
                            print("Unable to handle per-item errors in .batchRequestFailed error.")
                        } else {
                            // TODO: Retry with "saved" records. I can't really do anything because the records won't really encounter any per-item errors.... I'll do it once I figure which errors I need to actually worry about.
                            print("Tried to retry save operation for .batchRequestFailed error handling, but failed because of lack of implementation.")
                        }
                    }
                case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        print("Handling error by retrying...")
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.save(cloudUploadables, inDatabase: databaseType, recordChanged: recordChanged)
                            print("HANDLED ERROR BY RETRYING REQUEST")
                        }
                    }
                default:
                    break
                }
                
                return
            } else {
                print("Modified records error-free")
                completion(nil)
            }
        }
        
        operationQueue.addOperation(operation)
    }
    
    func delete(_ cloudUploadables: [CloudUploadable], inDatabase databaseType: DatabaseType, completion: @escaping () -> Void) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        
        switch databaseType {
        case .private:
            operation.database = privateDatabase
        case .shared:
            operation.database = sharedDatabase
        }
        
        // Map conversations to recordIDs
        let recordIDsToDelete = cloudUploadables.map { $0.ckRecord.recordID }
        operation.recordIDsToDelete = recordIDsToDelete
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            if let _ = ErrorHandler.handleCloudKitError(error, operation: .deleteRecords, affectedObjects: recordIDsToDelete) {
                // Handle error
                print("Error handling for delete operation is currently unimplemented.")
            } else {
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        // Check if the record is in a conversation the user actually owns or not, and delete it in the private or shared database... for now, do both, because it will simply ignore it if the record isn't found
        operationQueue.addOperation(operation)
    }
    
    func saveSubscription(for recordType: String, inDatabase databaseType: DatabaseType, completion: @escaping () -> Void) {
        // Create and save a silent push subscription in order to be updated:
        let subscriptionID = "cloudkit-\(databaseType.rawValue)\(recordType)-changes"
        print("Subscription ID: \(subscriptionID)")
        
        // Notify for all chnages
        let predicate = NSPredicate(value: true)
        
        // Initialize subscription
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        
        
        // Configure silent push notifications
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        notificationInfo.alertBody = "Received a change from your private database! (\(databaseType.rawValue))"
        subscription.notificationInfo = notificationInfo
        
        // Configure subscription operation
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        
        switch databaseType {
        case .private:
            operation.database = privateDatabase
            subscription.zoneID = zoneID
        case .shared:
            operation.database = sharedDatabase
        }
        
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            print("Succesfully added subscription")
            
            if let zoneID = subscription.zoneID, let ckError = ErrorHandler.handleCloudKitError(error, operation: .modifySubscriptions, affectedObjects: [zoneID]) {
                switch ckError.code {
                case .serviceUnavailable, .requestRateLimited, .zoneBusy:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        print("Handling error by retrying...")
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.saveSubscription(for: recordType, inDatabase: databaseType, completion: completion)
                            print("HANDLED ERROR BY RETRYING REQUEST")
                        }
                    }
                default:
                    break
                }
            } else {
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        operationQueue.addOperation(operation)
    }
    
    func saveNotificationSubscription(completion: @escaping () -> Void) {
        // Create and save a silent push subscription in order to be updated:
        let subscriptionID = "cloudkit-otheruser-changes"
        print("Subscription ID: \(subscriptionID)")
        
        // Notify for all chnages
        let predicate = NSPredicate(value: true)
        
        // Initialize subscription
        let subscription = CKQuerySubscription(
            recordType: RecordType.message.cloudValue,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation])
        
        
        // Configure silent push notifications
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "Something was updated in CloudMessage!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        
        // Configure subscription operation
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        
        operation.database = sharedDatabase
        
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            print("Succesfully added subscription")
            
            if let zoneID = subscription.zoneID, let ckError = ErrorHandler.handleCloudKitError(error, operation: .modifySubscriptions, affectedObjects: [zoneID]) {
                switch ckError.code {
                case .serviceUnavailable, .requestRateLimited, .zoneBusy:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        print("Handling error by retrying...")
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.saveSubscription(for: RecordType.message.cloudValue, inDatabase: .shared, completion: completion)
                            print("HANDLED ERROR BY RETRYING REQUEST")
                        }
                    }
                default:
                    break
                }
            } else {
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        operationQueue.addOperation(operation)
    }
    
    func saveSharedSubscription(completion: @escaping () -> Void) {
        // Create and save a silent push subscription in order to be updated:
        let subscriptionID = "cloudkit-sharedDatabase-changes"
        
        // Initialize subscription
        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "Got a message from the Cloud!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        // Configure subscription operation
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.database = sharedDatabase
        
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            print("Successfully added subscription")
            
            if let _ = ErrorHandler.handleCloudKitError(error, operation: .modifySubscriptions) {
                print("Save shared subscription error handling not yet implemented")
            } else {
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        operationQueue.addOperation(operation)
    }
    
    // Note: there could be a problem with change tokens where I commit them to memory too early - https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/MaintainingaLocalCacheofCloudKitRecords/MaintainingaLocalCacheofCloudKitRecords.html
    
    func fetchDatabaseChanges(inDatabase databaseType: DatabaseType, zonesDeleted: @escaping ([CKRecordZone.ID]) -> Void, saveChanges: @escaping ([CKRecord], [CKRecord.ID], DatabaseType) -> Void,
                              completion: @escaping () -> Void) {
        
        var changedZoneIDs = [CKRecordZone.ID]()
        var deletedZoneIDs = [CKRecordZone.ID]()
        
        let databaseChangeToken: CKServerChangeToken?
        switch databaseType {
        case .private:
            databaseChangeToken = privateDatabaseChangeToken
        case .shared:
            databaseChangeToken = sharedDatabaseChangeToken
        }
        
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseChangeToken)
        operation.fetchAllChanges = true
        
        switch databaseType {
        case .private:
            operation.database = privateDatabase
        case .shared:
            operation.database = sharedDatabase
        }
        
        operation.recordZoneWithIDChangedBlock = { (zoneID) in
            changedZoneIDs.insert(zoneID, at: 0)
        }
        
        operation.recordZoneWithIDWasDeletedBlock = { (zoneID) in
            deletedZoneIDs.insert(zoneID, at: 0)
        }
        
        operation.changeTokenUpdatedBlock = { (token) in
            zonesDeleted(deletedZoneIDs)
            
            // Don't update the change token since you're not saving any of the changes
        }
        
        operation.fetchDatabaseChangesCompletionBlock = { (token, moreComing, error) in
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchChanges) {
                // handle a few errors here if there are any
                print("ERROR: \(ckError), \(ckError.userInfo), \(ckError.localizedDescription)")
                switch ckError.code {
                case .changeTokenExpired:
                    switch databaseType {
                    case .private:
                        self.privateDatabaseChangeToken = nil
                    case .shared:
                        self.sharedDatabaseChangeToken = nil
                    }
                    self.fetchDatabaseChanges(inDatabase: databaseType, zonesDeleted: zonesDeleted, saveChanges: saveChanges, completion: completion)
                case .zoneNotFound:
                    self.createdCustomZone = false
                    self.createCustomZone(inDatabase: databaseType) {
                        self.fetchDatabaseChanges(inDatabase: databaseType, zonesDeleted: zonesDeleted, saveChanges: saveChanges, completion: completion)
                    }
                case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.fetchDatabaseChanges(inDatabase: databaseType, zonesDeleted: zonesDeleted, saveChanges: saveChanges, completion: completion)
                        }
                    }
                case .invalidArguments:
                    print("Didn't handle invalid arguments; not implemented")
                default:
                    break
                }
                
                return
            } else {
                zonesDeleted(deletedZoneIDs)
                switch databaseType {
                case .private:
                    self.privateDatabaseChangeToken = token
                case .shared:
                    self.sharedDatabaseChangeToken = token
                }
                
                if changedZoneIDs.count > 0 {
                    self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: changedZoneIDs, saveChanges: saveChanges) {
                        completion()
                    }
                } else {
                    print("No zones found changed")
                    completion()
                }
            }
        }
        operation.qualityOfService = .userInitiated
        
        operationQueue.addOperation(operation)
    }
    
    func fetchZoneChanges(inDatabase databaseType: DatabaseType, zoneIDs: [CKRecordZone.ID], saveChanges: @escaping ([CKRecord], [CKRecord.ID], DatabaseType) -> Void, completion: @escaping () -> Void) {
        // Memory for changed and deleted records
        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecord.ID] = []
        
        // Look up the previous change token for each zone
        var optionsByRecordZoneID = [CKRecordZone.ID: CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
        for zoneID in zoneIDs {
            let options = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            switch databaseType {
            case .private:
                options.previousServerChangeToken = self.privateZoneChangeToken
            case .shared:
                options.previousServerChangeToken = self.sharedZoneChangeToken
            }
            optionsByRecordZoneID[zoneID] = options
        }
        
        
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs, configurationsByRecordZoneID: optionsByRecordZoneID)
        operation.fetchAllChanges = true
        
        switch databaseType {
        case .private:
            operation.database = privateDatabase
        case .shared:
            operation.database = sharedDatabase
        }
        
        operation.recordChangedBlock = { (record) in
            print("Record changed in Cloud")
            changedRecords.insert(record, at: 0)
        }
        
        operation.recordWithIDWasDeletedBlock = { (recordID, _) in
            print("Record deleted from Cloud")
            deletedRecordIDs.insert(recordID, at: 0)
        }
        
        operation.recordZoneChangeTokensUpdatedBlock = { (zoneID, token, data) in
            //            switch databaseType {
            //            case .private:
            //                self.privateZoneChangeToken = token
            //            case .shared:
            //                self.sharedZoneChangeToken = token
            //            }
            //            saveChanges(changedRecords, deletedRecordIDs, databaseType)
        }
        
        operation.recordZoneFetchCompletionBlock = { (zoneID, token, lastChangeToken, moreComing, error) in
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchZones) {
                // handle a few errors here if there are any
                print("ERROR: \(ckError), \(ckError.userInfo), \(ckError.localizedDescription)")
                
                switch ckError.code {
                case .changeTokenExpired:
                    switch databaseType {
                    case .private:
                        self.privateZoneChangeToken = nil
                    case .shared:
                        self.sharedZoneChangeToken = nil
                    }
                    self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                case .zoneNotFound:
                    self.createdCustomZone = false
                    self.createCustomZone(inDatabase: databaseType) {
                        self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                    }
                case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                        }
                    }
                default:
                    break
                }
                
                return
            } else {
                saveChanges(changedRecords, deletedRecordIDs, databaseType)
                switch databaseType {
                case .private:
                    self.privateZoneChangeToken = token
                case .shared:
                    self.sharedZoneChangeToken = token
                }
            }
        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { (error) in
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchZones) {
                switch ckError.code {
                case .changeTokenExpired:
                    switch databaseType {
                    case .private:
                        self.privateZoneChangeToken = nil
                    case .shared:
                        self.sharedZoneChangeToken = nil
                    }
                    self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                case .zoneNotFound:
                    self.createdCustomZone = false
                    self.createCustomZone(inDatabase: databaseType) {
                        self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                    }
                case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                    if let retryAfterValue = ckError.userInfo[CKErrorRetryAfterKey] as? Double {
                        let delayTime = DispatchTime.now() + retryAfterValue
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.fetchZoneChanges(inDatabase: databaseType, zoneIDs: zoneIDs, saveChanges: saveChanges, completion: completion)
                        }
                    }
                default:
                    break
                }
            } else {
                completion()
            }
        }
        operation.qualityOfService = .userInitiated
        
        operationQueue.addOperation(operation)
    }
    
    func createCustomZone(inDatabase databaseType: DatabaseType, _ completion: @escaping () -> Void = { }) {
        let createZoneGroup = DispatchGroup()
        
        if !self.createdCustomZone {
            createZoneGroup.enter()
            
            let customZone = CKRecordZone(zoneID: zoneID)
            
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            
            switch databaseType {
            case .private:
                createZoneOperation.database = privateDatabase
            case .shared:
                createZoneOperation.database = sharedDatabase
            }
            
            createZoneOperation.modifyRecordZonesCompletionBlock = { (saved, deleted, error) in
                if let ckError = ErrorHandler.handleCloudKitError(error, operation: .modifyZones, affectedObjects: [customZone.zoneID]) {
                    print("ERROR from createCustomZone() \(ckError)\nHandle appropriately. I don't know when or what zone issues there might be.")
                    return
                } else {
                    self.createdCustomZone = true
                }
                
                createZoneGroup.leave()
                completion()
            }
            createZoneOperation.qualityOfService = .userInitiated
            
            operationQueue.addOperation(createZoneOperation)
        }
    }
    
    func acceptShare(withShareMetadata shareMetadata: CKShare.Metadata, completion: @escaping () -> Void) {
        let acceptShareOperation: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [shareMetadata])
        
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = { (meta, share, error) in
            print("Share was accepted")
        }
        
        acceptShareOperation.acceptSharesCompletionBlock = { error in
            completion()
        }
        
        CKContainer.default().add(acceptShareOperation)
    }
    
    func isRecordUserCreated(record: CKRecord, completion: @escaping (Bool) -> Void) {
        
    }
    
    init() {
        if !subscribedToChanges { // If there is no "!" before "subscribedToChanges", then I'm testing because I changed the subscriptions
            print("Subscribing to changes...")
            saveSubscription(for: "Conversation", inDatabase: .private) { }
            saveSubscription(for: "Message", inDatabase: .private) { }
            saveSharedSubscription() { }
            print("Subscribed to changes")
            //saveNotificationSubscription { print("Saved notification subscription. Should receive notifications when somebody else adds something to the cloud database.")}
        }
        subscribedToChanges = true
        
        createCustomZone(inDatabase: .private)
    }
    
    // MARK: - For testing
    
    func removeAllSubscriptions() {
        privateDatabase.fetchAllSubscriptions() { subscriptions, error in
            guard let subscriptions = subscriptions else { return }
            
            for subscription in subscriptions {
                self.privateDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (subscriptionID, _) in
                    print("Deleted subscription with ID: \(subscriptionID ?? "no subscription id")")
                })
            }
        }
        
        sharedDatabase.fetchAllSubscriptions() { subscriptions, error in
            guard let subscriptions = subscriptions else { return }
            
            for subscription in subscriptions {
                self.sharedDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (subscriptionID, _) in
                    print("Deleted subscription with ID: \(subscriptionID ?? "no subscription id")")
                })
            }
        }
        
        subscribedToChanges = false
    }
}
