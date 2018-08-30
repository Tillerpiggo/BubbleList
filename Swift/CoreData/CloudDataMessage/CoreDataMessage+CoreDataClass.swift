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

@objc(CoreDataMessage)
public class CoreDataMessage: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Message")
    
    init(withText text: String, timestamp: Date, managedContext: NSManagedObjectContext, owningConversation: CKReference, zoneID: CKRecordZoneID) {
        let messageDescription = NSEntityDescription.entity(forEntityName: "CoreDataMessage", in: managedContext)
        super.init(entity: messageDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.timestamp = timestamp as NSDate
        self.encodedSystemFields = ckRecord.encoded()
        
        // Create CKRecord
        let newCKRecord = CKRecord(recordType: "Message", zoneID: zoneID)
        newCKRecord["text"] = text as CKRecordValue
        newCKRecord["owningConversation"] = owningConversation as CKRecordValue
        
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        let messageDescription = NSEntityDescription.entity(forEntityName: "CoreDataMessage", in: managedContext)
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
}

extension CoreDataMessage: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
