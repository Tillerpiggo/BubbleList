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
            print("fetched record")
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.mergeConversations(with: fetchedConversations)
            completionHandler(self.conversations)
        }
        
        get(.publicDatabase).add(operation)
    }
    
    private func mergeConversations(with newConversations: [Conversation]) {
        // Merge a new set of conversations with new conversations
        
        // Merged conversations starts out as the new conversations, and a bit of info is
        // Filled in by the old conversations, such as messages
        let mergedConversations = sortedConversations(newConversations, by: .dateCreated, reverse: true)
        let oldConversations = sortedConversations(conversations, by: .dateCreated, reverse: true) // Reverse so that the newest ones are at the end
        
        if oldConversations.count == newConversations.count { // Something was edited
            for (index, mergedConversation) in mergedConversations.enumerated() {
                // Add messages (because you don't fetch messages from the Cloud, just conversations)
                
                // IMPORTANT NOTE: This won't overwrite the messages
                // (which could've been updated) entirely,It simply gives the
                //  conversation something to display until it fetches the messages
                mergedConversation.messages = oldConversations[index].messages
            }
        } else if oldConversations.count < newConversations.count { // Some thing(s) were added
            // Won't iterate through the newly added conversations
            for (index, oldConversation) in oldConversations.enumerated() {
                mergedConversations[index].messages = oldConversation.messages
            }
        } else if oldConversations.count > newConversations.count { // Some thing(s) were deleted
            // Determine what was deleted somehow - maybe request that from the server?
            // Then delete that index from oldConversations and fill in message data
            
            // Do nothing... yet
        }
        
        conversations = mergedConversations
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
