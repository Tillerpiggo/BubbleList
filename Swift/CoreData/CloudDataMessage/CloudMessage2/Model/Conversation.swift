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
            ckRecord["latestMessage"] = latestMessage as CKRecordValue
            return latestMessage
        } else if let latestMessage = ckRecord["latestMessage"] as? String {
            return latestMessage
        } else {
            ckRecord["latestMessage"] = "" as CKRecordValue
            return ""
        }
    }
    
    // MARK: - Core Data
    var coreDataConversation: CoreDataConversation
    var coreData: NSManagedObject {
        return coreDataConversation
    }
    
    func update(withRecord record: CKRecord) {
        coreDataConversation.title = record["title"] as? String
        if let creationDate = record.creationDate as NSDate? { coreDataConversation.creationDate = creationDate }
        if let dateLastModified = record.modificationDate as NSDate? { coreDataConversation.dateLastModified = dateLastModified }
        coreDataConversation.encodedSystemFields = record.encoded()
    }
    
    // MARK: - Cloud
    var ckRecord: CKRecord
    
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
        newCoreDataConversation.encodedSystemFields = record.encoded()
        
        self.coreDataConversation = newCoreDataConversation
        
        // Create CKRecord
        self.ckRecord = record
    }
    
    init(fromCoreDataConversation newCoreDataConversation: CoreDataConversation) {
        self.coreDataConversation = newCoreDataConversation
        
        // Create CKRecord from an unarchiver
        let newCKRecord: CKRecord
        
        if let encodedSystemFields = coreDataConversation.encodedSystemFields {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
        } else {
            newCKRecord = CKRecord(recordType: "Conversation")
        }
        
        newCKRecord["title"] = newCoreDataConversation.title as CKRecordValue?
        if let latestMessage = newCoreDataConversation.messages?.firstObject as? CoreDataMessage {
            newCKRecord["latestMessage"] = (latestMessage.text ?? "") as CKRecordValue
        }
        self.ckRecord = newCKRecord
    }
}
