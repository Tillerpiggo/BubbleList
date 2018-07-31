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

protocol MessageModelControllerDelegate {
    func didChangeConversation(_ conversation: Conversation)
}

extension MessageModelController {
    private enum DatabaseType {
        case databasePrivate
        case databaseShared
        case databasePublic
    }
    
    private func getDatabase(type: DatabaseType) -> CKDatabase {
        switch type {
        case .databasePrivate:
            return CKContainer.default().privateCloudDatabase
        case .databaseShared:
            return CKContainer.default().sharedCloudDatabase
        case .databasePublic:
            return CKContainer.default().publicCloudDatabase
        }
    }
    
    func fetchMessages(completionHandler: @escaping (Conversation) -> Void) {
        // search for all messages tied to a certain conversation:
        
        guard let listID = conversation.ckRecord?.recordID else { return }
        
        let recordToMatch = CKReference(recordID: listID, action: .deleteSelf)
        let predicate = NSPredicate(format: "owningConversation == %@", recordToMatch)
        
        let query = CKQuery(recordType: "Message", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        let fetchedConversation = Conversation(withTitle: conversation.title)
        operation.recordFetchedBlock = { record in
            fetchedConversation.messages.append(Message(withRecord: record))
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.conversation = fetchedConversation
            completionHandler(self.conversation)
        }
    }
    
    func saveConversation(_ conversation: Conversation, completionHandler: @escaping () -> Void) {
        /* figure out later
        let operation = CKModifyRecordsOperation()
        let optionalRecordsToSave = conversation
        
        operation.recordsToSave = optionalRecordsToSave.filter { $0 != nil } as? [CKRecord]
        operation.isAtomic = true
        
        operation.modifyRecordsCompletionBlock = { (record, recordID, error) in
            // handle error
            if let error = error {
                print(error.localizedDescription)
            }
        }
         */
    }
}
