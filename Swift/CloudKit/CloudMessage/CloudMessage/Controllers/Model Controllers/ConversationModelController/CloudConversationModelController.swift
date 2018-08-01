//
//  CloudConversationModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

// Cloud Stuff

extension ConversationModelController {

    private enum DatabaseType {
        case privateDatabase
        case sharedDatabase
        case publicDatabase
    }
    
    private func get(_ type: DatabaseType) -> CKDatabase {
        switch type {
        case .privateDatabase:
            return CKContainer.default().privateCloudDatabase
        case .sharedDatabase:
            return CKContainer.default().sharedCloudDatabase
        case .publicDatabase:
            return CKContainer.default().publicCloudDatabase
        }
    }
    
    func fetchConversations(completionHandler: @escaping ([Conversation]) -> Void) {
        // Search for all conversations in the Cloud
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Conversation", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var fetchedConversations = [Conversation]()
        operation.recordFetchedBlock = { record in
            fetchedConversations.append(Conversation(withRecord: record))
            //print("fetched record")
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.conversations = self.mergeConversations(self.conversations, with: fetchedConversations)
            completionHandler(self.conversations)
        }
        
        get(.publicDatabase).add(operation)
    }
    
    func saveConversations(_ conversations: [Conversation], completionHandler: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation()
        
        let optionalRecordsToSave = conversations.map { $0.ckRecord }
        operation.recordsToSave = optionalRecordsToSave.filter { $0 != nil } as? [CKRecord]
        
        print("Attempting to save conversations")
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
            
            completionHandler()
        }
        
        get(.publicDatabase).add(operation)
    }
    
    func deleteConversations(_ conversations: [Conversation], completionHandler: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation()
        
        let optionalRecordIDsToDelete = conversations.map { $0.ckRecord?.recordID }
        operation.recordIDsToDelete = optionalRecordIDsToDelete.filter { $0 != nil } as? [CKRecordID]
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
            
            completionHandler()
            print("deleted conversation")
        }
        
        get(.publicDatabase).add(operation)
    }
}
