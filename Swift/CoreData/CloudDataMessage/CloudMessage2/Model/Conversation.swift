//
//  Conversation.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//



import Foundation
import CloudKit
import CoreData

class Conversation: CloudUploadable { // NSObject, NSCoding {
    
    // MARK: - Properties
    
    var messages: [Message]
    var creationDate: Date
    var dateLastModified: Date
    var title: String
    
    var latestMessage: String {
        // Use the text of the first messasge, if that isn't there, use latestMessage, otherwise, it's blank.
        if let latestMessage = messages.first?.text {
            ckRecord?["latestMessage"] = latestMessage as CKRecordValue
            return latestMessage
        } else if let latestMessage = ckRecord?["latestMessage"] as? String {
            return latestMessage
        } else {
            ckRecord?["latestMessage"] = "" as CKRecordValue
            return ""
        }
    }
    
    // MARK: - Core Data
    var coreDataConversation: CoreDataConversation
    
    // MARK: - Cloud
    var ckRecord: CKRecord?
    var ckRecordSystemFields: NSMutableData
    
    // MARK: - Initializers
    
    init(withTitle title: String, messages: [Message] = [Message](), managedContext: NSManagedObjectContext) {
        // Create CoreDataConversation
        let newCoreDataConversation = CoreDataConversation(context: managedContext)
        newCoreDataConversation.title = title
        newCoreDataConversation.messages = messages.map { $0.coreDataMessage }
        
        // Properties
        self.title = title
        self.messages = messages
        self.creationDate = Date()
        self.dateLastModified = Date()
        self.ckRecordSystemFields = NSMutableData()
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord) {
        // Properties
        self.title = record["title"] as! String
        self.messages = [Message]()
        self.creationDate = record.creationDate ?? Date()
        self.dateLastModified = record.modificationDate ?? Date()
        self.ckRecordSystemFields = NSMutableData()
        
        // CKRecord
        self.ckRecord = record
    }
}
