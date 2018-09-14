//
//  Message+CoreDataClass.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class Message: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Message")
    
    var formattedTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let formattedTimestamp = dateFormatter.string(from: timestamp! as Date)
        return formattedTimestamp
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withText text: String, timestamp: Date, managedContext: NSManagedObjectContext, owningConversation: CKRecord, zoneID: CKRecordZoneID) {
        let messageDescription = NSEntityDescription.entity(forEntityName: "Message", in: managedContext)
        super.init(entity: messageDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.timestamp = timestamp as NSDate
        self.encodedSystemFields = ckRecord.encoded()
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Message", zoneID: zoneID)
        newCKRecord["text"] = text as CKRecordValue
        
        let owningConversationReference = CKReference(record: owningConversation, action: .deleteSelf)
        newCKRecord["owningConversation"] = owningConversationReference as CKRecordValue
        newCKRecord.setParent(owningConversation)
        
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        let messageDescription = NSEntityDescription.entity(forEntityName: "Message", in: managedContext)
        super.init(entity: messageDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = record["text"] as? String
        self.timestamp = record.creationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        
        // Set CKRecord
        self.ckRecord = record
    }
    
    func update(withRecord record: CKRecord) {
        self.text = record["text"] as? String
        self.timestamp = record.creationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        
        self.ckRecord = record
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["text"] = text as CKRecordValue?
            // TODO: Figure out how to have owningConversation (or ignore)
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata; encodedSystemFields not found")
        }
    }
}

extension Message: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
