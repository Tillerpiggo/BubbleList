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

@objc(CoreDataConversation)
public class CoreDataConversation: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Conversation")
    
    init(withTitle title: String, messages: [Message] = [Message](), managedContext: NSManagedObjectContext, zoneID: CKRecordZoneID) {
        let conversationDescription = NSEntityDescription.entity(forEntityName: "CoreDataConversation", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Set properties
        self.title = title
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.encodedSystemFields = ckRecord.encoded()
        
        for message in messages {
            self.addToMessages(message.coreDataMessage)
        }
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation", zoneID: zoneID)
        
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
        
        self.ckRecord = newCKRecord
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
}

extension CoreDataConversation: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
