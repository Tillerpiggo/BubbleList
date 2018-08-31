//
//  Conversation+CoreDataClass.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class CoreDataConversation: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Conversation")
    
    var latestMessage: String {
        if let latestMessage = messages?.lastObject as? CoreDataMessage, let text = latestMessage.text {
            return text
        } else {
            return ""
        }
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withTitle title: String, messages: [CoreDataMessage] = [CoreDataMessage](), managedContext: NSManagedObjectContext, zoneID: CKRecordZoneID) {
        let conversationDescription = NSEntityDescription.entity(forEntityName: "CoreDataConversation", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Configure CKRecord
        ckRecord["title"] = title as CKRecordValue
        ckRecord["latestMessage"] = latestMessage as CKRecordValue
        
        // Set properties
        self.title = title
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.encodedSystemFields = ckRecord.encoded()
        
        for message in messages {
            self.addToMessages(message)
        }
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        let conversationDescription = NSEntityDescription.entity(forEntityName: "CoreDataConversation", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Set properties
        self.title = record["title"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        
        // Set CKRecord
        self.ckRecord = record
    }
    
    func update(withRecord record: CKRecord) {
        self.title = record["title"] as? String
        if let creationDate = record.creationDate as NSDate? { self.creationDate = creationDate }
        if let dateLastModified = record.modificationDate as NSDate? { self.dateLastModified = dateLastModified }
        self.encodedSystemFields = record.encoded()
        
        self.ckRecord = record
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["title"] = title as CKRecordValue?
            newCKRecord["latestMessage"] = latestMessage as CKRecordValue
        }
    }
}

extension CoreDataConversation: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
