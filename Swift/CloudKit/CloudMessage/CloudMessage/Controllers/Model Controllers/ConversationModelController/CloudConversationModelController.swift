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
            let fetchedConversation = Conversation(fromRecord: record)
            fetchedConversations.append(fetchedConversation)
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
    
    func fetchFirstMessage(of conversation: Conversation, completionHandler: @escaping(Message) -> Void) {
        // Search for messages of a conversation
        guard let listID = conversation.ckRecord?.recordID else { return }
        
        let recordToMatch = CKReference(recordID: listID, action: .deleteSelf)
        let predicate = NSPredicate(format: "owningConversation == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Message", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        
        operation.recordFetchedBlock = { record in
            let fetchedMessage = Message(fromRecord: record)
            completionHandler(fetchedMessage)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        get(.publicDatabase).add(operation)
    }
    
    /*
    func fetchMessages(completionHandler: @escaping (Conversation) -> Void) {
        // search for all messages tied to a certain conversation:
        
        guard let listID = conversation.ckRecord?.recordID else {
            print("Could not find record ID")
            return
        }
        
        let recordToMatch = CKReference(recordID: listID, action: .deleteSelf)
        let predicate = NSPredicate(format: "owningConversation == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Message", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        let fetchedConversation = Conversation(withTitle: conversation.title)
        operation.recordFetchedBlock = { record in
            fetchedConversation.messages.append(Message(withRecord: record))
            //print("fetched message")
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
                print("did not succesfully fetch message")
            }
            
            self.conversation.messages = fetchedConversation.messages
            
            print("Fetched Conversation: (\(fetchedConversation.messages.count))")
            
            completionHandler(self.conversation)
        }
        
        get(.publicDatabase).add(operation)
    }
    */
    
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
