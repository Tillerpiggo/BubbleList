//
//  Message.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//


import Foundation
import CloudKit
import CoreData

class Message: CloudUploadable, CoreDataUploadable {
    
    // PROPERTIES:
    
    var text: String { return coreDataMessage.text ?? "" }
    var timestamp: Date { return (coreDataMessage.timestamp ?? NSDate()) as Date }
    
    var formattedTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let formattedTimestamp = dateFormatter.string(from: timestamp)
        return formattedTimestamp
    }
    
    // Core Data
    var coreDataMessage: CoreDataMessage
    var coreData: NSManagedObject {
        return coreDataMessage
    }
    
    // Cloud
    var ckRecord: CKRecord // remember to set parent property
    
    // INITIALIZERS:
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        // Create CoreDataMessage
        let newCoreDataMessage = CoreDataMessage(context: managedContext)
        newCoreDataMessage.text = record["text"] as? String
        newCoreDataMessage.timestamp = record.creationDate! as NSDate
        
        self.coreDataMessage = newCoreDataMessage
        
        // Create CKRecord
        self.ckRecord = record
    }
    
    init(fromCoreDataMessage coreDataMessage: CoreDataMessage) {
        self.coreDataMessage = coreDataMessage
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: RecordType.message.cloudValue)
        newCKRecord["text"] = coreDataMessage.text as CKRecordValue?
        
        // TODO: Set owning conversation
        
        self.ckRecord = newCKRecord
        
        // TODO: Add owning conversation of message from core data
    }
    
    init(withText text: String, timestamp: Date, managedContext: NSManagedObjectContext, owningConversation: CKReference) {
        // Create CoreDataMessage
        let newCoreDataMessage = CoreDataMessage(context: managedContext)
        newCoreDataMessage.text = text
        newCoreDataMessage.timestamp = timestamp as NSDate
        
        self.coreDataMessage = newCoreDataMessage
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: RecordType.message.cloudValue)
        newCKRecord["text"] = text as CKRecordValue
        newCKRecord["owningConversation"] = owningConversation as CKRecordValue
        
        self.ckRecord = newCKRecord
    }
}
