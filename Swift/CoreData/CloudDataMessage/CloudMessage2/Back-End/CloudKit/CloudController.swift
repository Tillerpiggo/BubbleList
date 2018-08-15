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
    
    var database = CKContainer.default().publicCloudDatabase // Change depending on needs, may include zone as well
    
    func fetchRecords(ofType recordType: RecordType, perZoneCompletion: @escaping ([CKRecord]) -> Void) {
        // Create and configure fetchAllRecordZonesOperation
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.database = database
        
        var fetchedRecords = [CKRecord]()
        
        operation.fetchRecordZonesCompletionBlock = { (recordZones, error) in
            self.handleError(error)
            
            guard let recordZones = recordZones else { return }
            
            // Get all the zoneIDs from recordZones (the tuple (recordZoneID, recordZone)
            for zoneID in recordZones.map({ $0.0 }) {
                self.fetchRecordsOfType(recordType, inZone: zoneID) { (records) in
                    records.forEach() { fetchedRecords.append($0) }
                    perZoneCompletion(fetchedRecords)
                }
            }
        }
        
        database.add(operation)
    }
    
    // Fetches conversations of a particular zone, does not include any messages. REMINDER: Add a firstMessage property to a conversation record type
    private func fetchRecordsOfType(_ recordType: RecordType, inZone zoneID: CKRecordZoneID, completion: @escaping ([CKRecord]) -> Void) {
        // Search for ALL conversations in a particular zone in the Cloud:
        
        // Create query
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType.cloudValue, predicate: predicate)
        
        // Create and configure operation
        let operation = CKQueryOperation(query: query)
        operation.zoneID = zoneID
        
        var fetchedRecords = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            self.handleError(error)
            
            completion(fetchedRecords)
        }
        
        // Add/start the operation
        database.add(operation)
    }
    
    func fetchRecords(ofType recordType: RecordType, withParent parent: CloudUploadable, completion: @escaping ([CKRecord]) -> Void) {
        // Search for all messages that belong to a certain conversation in the Cloud:
        
        // Find ID of parent:
        guard let parentRecordID = parent.ckRecord?.recordID else { return }
        
        // Create query
        let parentReference = CKReference(recordID: parentRecordID, action: .none)
        let predicate = NSPredicate(format: "owningConversation == %@", parentReference) // The name of this field needs to be changing (owningList, owningClass, etc.)
        
        let query = CKQuery(recordType: recordType.cloudValue, predicate: predicate)
        
        // Create operation
        let operation = CKQueryOperation(query: query)
        
        var fetchedRecords = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            self.handleError(error)
            
            completion(fetchedRecords)
        }
        
        
        // Add/start the operation
        database.add(operation)
    }
    
    // REMINDER: Might be able to fuse save/delete conversations and save/delete messages
    
    // Saves the given conversations
    func save(_ cloudUploadables: [CloudUploadable], completion: @escaping () -> Void) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        operation.savePolicy = .changedKeys
        
        // Map conversations to records
        let recordsToSave = cloudUploadables.map() { $0.ckRecord! }
        operation.recordsToSave = recordsToSave
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            self.handleError(error)
            
            completion()
        }
        
        // Add/start the operation
        database.add(operation)
    }
    
    func delete(_ cloudUploadables: [CloudUploadable], completion: @escaping () -> Void) {
        // Create and configure operation
        let operation = CKModifyRecordsOperation()
        
        // Map conversations to recordIDs
        let recordIDsToDelete = cloudUploadables.map { $0.ckRecord!.recordID }
        operation.recordIDsToDelete = recordIDsToDelete
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            self.handleError(error)
            
            completion()
        }
        
        // Add/start the operation
        database.add(operation)
    }
    
    func saveSubscription(for recordType: String, completion: @escaping () -> Void) {
        // Create and save a silent push subscription in order to be updated:
        let subscriptionID = "cloudit-\(recordType)-changes"
        
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
            self.handleError(error)
            
            completion()
        }
        
        database.add(operation)
    }
    
    func handleError(_ error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
            print(error)
        }
    }
}
