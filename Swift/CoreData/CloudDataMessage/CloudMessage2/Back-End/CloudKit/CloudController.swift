//
//  Cloud.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

// An object that allows you to save and fetch data from the Cloud

class CloudController {
    
    var privateDatabase = CKContainer.default().privateCloudDatabase
    var sharedDatabase = CKContainer.default().sharedCloudDatabase
    
    let zoneID = CKRecordZoneID(zoneName: "CloudMessage", ownerName: CKCurrentUserDefaultName)
    
    var createdCustomZone: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "createdCustomZone")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "createdCustomZone")
        }
    }
    
    var subscribedToPrivateChanges: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "subscribedToPrivateChanges")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "subscribedToPrivateChanges")
        }
    }
    
    var privateDatabaseChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "privateDatabaseChangeToken") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: "privateDatabaseChangeToken")
        }
    }
    
    var sharedDatabaseChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "sharedDatabaseChangeToken") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: "sharedDatabaseChangeToken")
        }
    }
    
    var zoneChangeToken: CKServerChangeToken? {
        get {
            if let data = UserDefaults.standard.data(forKey: "zoneChangeToken") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken
            } else {
                return nil
            }
        }
        set {
            guard let newValue = newValue else { return }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: "zoneChangeToken")
        }
    }
    
    enum DatabaseType {
        case `private`
        case shared
    }
    
    var operationIsInProgress: Bool = false
    
    // Saves the given cloud up
    func save(_ cloudUploadables: [CloudUploadable], inDatabase databaseType: DatabaseType, recordChanged: @escaping (CKRecord) -> Void, willRetry: Bool = true, completion: @escaping (Error?) -> Void = { (error) in }) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        operation.savePolicy = .ifServerRecordUnchanged
        operation.isAtomic = true
        
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
                    // Overwrite the server record
                    guard let serverRecord = ckError.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord,
                    let clientRecord = ckError.userInfo[CKRecordChangedErrorClientRecordKey] as? CKRecord else {
                        print("Could not get the necessary records to merge in CloudController.save error handling (.serverRecordChanged)")
                        return
                    }
                    
                    if clientRecord.recordType == "Conversation" {
                        serverRecord["title"] = clientRecord["title"]
                        serverRecord["latestMessage"] = clientRecord["latestMessage"]
                        
                        recordChanged(serverRecord)
                        
                        print("Merged Record (Conversation)")
                        
                        if willRetry {
                            self.save([serverRecord], inDatabase: databaseType, recordChanged: recordChanged, willRetry: false)
                            print(".serverRecordChanged (Conversation). Retried after merging.")
                        }
                    } else if clientRecord.recordType == "Message" {
                        serverRecord["text"] = clientRecord["text"]
                        serverRecord["timestamp"] = clientRecord["timestamp"]
                        
                        recordChanged(serverRecord)
                        
                        print("Merged Record (Message)")
                        
                        if willRetry {
                            self.save([serverRecord], inDatabase: databaseType, recordChanged: recordChanged, willRetry: false)
                            print(".serverRecordChanged (Message). Retried after merging.")
                        }
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
                        guard let failedRecordID = failedRecordID as? CKRecordID, let failedError = failedError as? Error else { return }
                        
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
        
        switch databaseType {
        case .private:
            privateDatabase.add(operation)
        case .shared:
            sharedDatabase.add(operation)
        }
    }
    
    func delete(_ cloudUploadables: [CloudUploadable], inDatabase databaseType: DatabaseType, completion: @escaping () -> Void) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        
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
        switch databaseType {
        case .private:
            privateDatabase.add(operation)
        case .shared:
            sharedDatabase.add(operation)
        }
    }
    
    func saveSubscription(for recordType: String, inDatabase databaseType: DatabaseType, completion: @escaping () -> Void) {
        if !subscribedToPrivateChanges {
            // Create and save a silent push subscription in order to be updated:
            let subscriptionID = "cloudkit-\(recordType)-changes"
        
            // Notify for all chnages
            let predicate = NSPredicate(value: true)
        
            // Initialize subscription
            let subscription = CKQuerySubscription(
                recordType: recordType,
                predicate: predicate,
                subscriptionID: subscriptionID,
                options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        
            // Configure silent push notifications
            let notificationInfo = CKNotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo
        
            // Configure subscription operation
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
            
        
            operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
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
            
            switch databaseType {
            case .private:
                privateDatabase.add(operation)
            case .shared:
                sharedDatabase.add(operation)
            }
            
            subscribedToPrivateChanges = true
        }
    }
    
    // Note: there could be a problem with change tokens where I commit them to memory too early - https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/MaintainingaLocalCacheofCloudKitRecords/MaintainingaLocalCacheofCloudKitRecords.html
    
    func fetchDatabaseChanges(inDatabase databaseType: DatabaseType, zonesDeleted: @escaping ([CKRecordZoneID]) -> Void, saveChanges: @escaping ([CKRecord], [CKRecordID]) -> Void,
                              completion: @escaping () -> Void) {
        
        var changedZoneIDs = [CKRecordZoneID]()
        var deletedZoneIDs = [CKRecordZoneID]()
        
        var databaseChangeToken: CKServerChangeToken?
        switch databaseType {
        case .private:
            databaseChangeToken = privateDatabaseChangeToken
        case .shared:
            databaseChangeToken = sharedDatabaseChangeToken
        }
        
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseChangeToken)
        operation.fetchAllChanges = true
        
        
        operation.recordZoneWithIDChangedBlock = { (zoneID) in
            changedZoneIDs.append(zoneID)
        }
        
        operation.recordZoneWithIDWasDeletedBlock = { (zoneID) in
            deletedZoneIDs.append(zoneID)
        }
        
        operation.changeTokenUpdatedBlock = { (token) in
            zonesDeleted(deletedZoneIDs)
            databaseChangeToken = token
        }
        
        operation.fetchDatabaseChangesCompletionBlock = { (token, moreComing, error) in
             if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchZones) {
                // handle a few errors here if there are any
                print("ERROR: \(ckError), \(ckError.userInfo), \(ckError.localizedDescription)")
                
                switch ckError.code {
                case .changeTokenExpired:
                    databaseChangeToken = nil
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
                default:
                    break
                }
                
                return
             } else {
                zonesDeleted(deletedZoneIDs)
                databaseChangeToken = token
                
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
        
        switch databaseType {
        case .private:
            privateDatabase.add(operation)
        case .shared:
            sharedDatabase.add(operation)
        }
    }
    
    func fetchZoneChanges(inDatabase databaseType: DatabaseType, zoneIDs: [CKRecordZoneID], saveChanges: @escaping ([CKRecord], [CKRecordID]) -> Void, completion: @escaping () -> Void) {
        // Memory for changed and deleted records
        var changedRecords: [CKRecord] = []
        var deletedRecordIDs: [CKRecordID] = []
        
        // Get the proper database change token
        var databaseChangeToken: CKServerChangeToken?
        switch databaseType {
        case .private:
            databaseChangeToken = privateDatabaseChangeToken
        case .shared:
            databaseChangeToken = sharedDatabaseChangeToken
        }
        
        // Look up the previous change token for each zone
        var optionsByRecordZoneID = [CKRecordZoneID: CKFetchRecordZoneChangesOptions]()
        for zoneID in zoneIDs {
            let options = CKFetchRecordZoneChangesOptions()
            options.previousServerChangeToken = self.zoneChangeToken
            optionsByRecordZoneID[zoneID] = options
        }
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zoneIDs, optionsByRecordZoneID: optionsByRecordZoneID)
        operation.fetchAllChanges = true
        
        
        operation.recordChangedBlock = { (record) in
            print("Record changed in Cloud")
            changedRecords.append(record)
        }
        
        operation.recordWithIDWasDeletedBlock = { (recordID, _) in
            print("Record deleted from Cloud")
            deletedRecordIDs.append(recordID)
        }
        
        operation.recordZoneChangeTokensUpdatedBlock = { (zoneID, token, data) in
            self.zoneChangeToken = token
            saveChanges(changedRecords, deletedRecordIDs)
        }
        
        operation.recordZoneFetchCompletionBlock = { (zoneID, token, _, _, error) in
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchZones) {
                // handle a few errors here if there are any
                print("ERROR: \(ckError), \(ckError.userInfo), \(ckError.localizedDescription)")
                
                switch ckError.code {
                case .changeTokenExpired:
                    databaseChangeToken = nil
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
                saveChanges(changedRecords, deletedRecordIDs)
                self.zoneChangeToken = token
            }
        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { (error) in
            if let ckError = ErrorHandler.handleCloudKitError(error, operation: .fetchZones) {
                switch ckError.code {
                case .changeTokenExpired:
                    databaseChangeToken = nil
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
        
        switch databaseType {
        case .private:
            privateDatabase.add(operation)
            break
        case .shared:
            sharedDatabase.add(operation)
            break
        }
    }
    
    func createCustomZone(inDatabase databaseType: DatabaseType, _ completion: @escaping () -> Void = { }) {
        let createZoneGroup = DispatchGroup()
        
        if !self.createdCustomZone {
            createZoneGroup.enter()
            
            let customZone = CKRecordZone(zoneID: zoneID)
            
            let createZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [customZone], recordZoneIDsToDelete: [])
            
            
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
            
            switch databaseType {
            case .private:
                privateDatabase.add(createZoneOperation)
            case .shared:
                sharedDatabase.add(createZoneOperation)
            }
        }
    }
    
    func acceptShare(withShareMetadata shareMetadata: CKShareMetadata, completion: @escaping () -> Void) {
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
    
    init() {
        saveSubscription(for: "Conversation", inDatabase: .private) { }
        saveSubscription(for: "Message", inDatabase: .private) { }
        saveSubscription(for: "Conversation", inDatabase: .shared) { }
        saveSubscription(for: "Message", inDatabase: .shared) { }
        
        createCustomZone(inDatabase: .private)
    }
}
