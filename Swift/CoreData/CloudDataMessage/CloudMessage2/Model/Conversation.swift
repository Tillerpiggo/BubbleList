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

class Conversation: CloudUploadable, CoreDataUploadable {
    
    // MARK: - Properties
    
    var messages: [Message] {
        guard let coreDataMessages = coreDataConversation.messages else { return [Message]() }
        return (coreDataMessages.map() { Message(fromCoreDataMessage: $0 as! CoreDataMessage) }).sorted() { $0.timestamp > $1.timestamp }
    }
    var creationDate: Date { return (coreDataConversation.creationDate ?? NSDate()) as Date }
    var dateLastModified: Date { return (coreDataConversation.dateLastModified ?? NSDate()) as Date }
    var title: String { return coreDataConversation.title ?? "" }
    
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
    var coreData: NSManagedObject {
        return coreDataConversation
    }
    
    // MARK: - Cloud
    var ckRecord: CKRecord?
    
    // MARK: - Initializers
    
    init(withTitle title: String, messages: [Message] = [Message](), managedContext: NSManagedObjectContext) {
        // Create CoreDataConversation
        let newCoreDataConversation = CoreDataConversation(context: managedContext)
        newCoreDataConversation.title = title
        for message in messages {
            newCoreDataConversation.addToMessages(message.coreDataMessage)
        }
        newCoreDataConversation.creationDate = NSDate()
        newCoreDataConversation.dateLastModified = NSDate()
        self.coreDataConversation = newCoreDataConversation
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        // Create CoreDataConversation
        let newCoreDataConversation = CoreDataConversation(context: managedContext)
        newCoreDataConversation.title = record["title"] as? String
        newCoreDataConversation.creationDate = (record.creationDate ?? Date()) as NSDate
        newCoreDataConversation.dateLastModified = (record.modificationDate ?? Date()) as NSDate
        self.coreDataConversation = newCoreDataConversation
        
        // Create CKRecord
        self.ckRecord = record
    }
    
    init(fromCoreDataConversation coreDataConversation: CoreDataConversation) {
        self.coreDataConversation = coreDataConversation
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
    }
}
