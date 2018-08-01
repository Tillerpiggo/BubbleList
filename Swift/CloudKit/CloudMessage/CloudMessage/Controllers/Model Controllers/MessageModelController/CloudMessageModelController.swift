//
//  CloudMessageModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

// Cloud stuff

extension MessageModelController {
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
            fetchedConversation.messages.append(Message(fromRecord: record))
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
    
    func saveMessages(in conversation: Conversation, completionHandler: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation()
        
        let optionalRecordsToSave = conversation.messages.map { $0.ckRecord }
        operation.recordsToSave = optionalRecordsToSave.filter { $0 != nil } as? [CKRecord]
        
        print("Attempting to save messages")
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
            
            completionHandler()
        }
        
        get(.publicDatabase).add(operation)
    }
    
    func deleteMessages(_ messages: [Message], completionHandler: @escaping () -> Void) {
        let operation = CKModifyRecordsOperation()
        
        let optionalRecordIDsToDelete = conversation.messages.map { $0.ckRecord?.recordID }
        operation.recordIDsToDelete = optionalRecordIDsToDelete.filter { $0 != nil } as? [CKRecordID]
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
            
            completionHandler()
            print("deleted message")
        }
        
        get(.publicDatabase).add(operation)
    }
}

extension MessageModelController {
    // ON-DEVICE STORAGE:
    
    func saveToFile(_ conversation: Conversation) {
        // tell ConversationModelController to do it for you
        delegate?.didChangeConversation(conversation)
    }
}
