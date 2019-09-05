//
//  Class+CoreDataClass.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


public class Class: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Class") // This is only so NSManagedObject stops complaining. It shouldn't be used.
    
    var latestAssignment: String {
//        let compareBlock: (Message, Message) -> Bool = { (message1, message2) in
//            guard let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp else { return false }
//            let comparisonResult = timestamp1.compare(timestamp2 as Date)
//
//            switch comparisonResult {
//            case .orderedSame:
//                return false
//            case .orderedAscending:
//                return true
//            case .orderedDescending:
//                return false
//            }
//        }
//
//        if let latestMessage = messageArray?.max(by: compareBlock), let text = latestMessage.text {
//            return text
//        } else {
//            return ""
//        }
        
        // To implement
    }
    
    var assignmentArray: [Assignment]? {
        if let assignmentArray = assignments?.array as? [Message] {
            return assignmentArray
        } else {
            return nil
        }
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withTitle title: String, messages: [Assignment] = [Message](), managedContext: NSManagedObjectContext, zoneID: CKRecordZoneID) {
        let conversationDescription = NSEntityDescription.entity(forEntityName: "Conversation", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Configure CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation", zoneID: zoneID)
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = latestMessage as CKRecordValue
        self.ckRecord = newCKRecord
        
        // Set properties
        self.title = title
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.encodedSystemFields = ckRecord.encoded()
        self.isUserCreated = true
        
        for message in messages {
            self.addToMessages(message)
            message.owningConversation = self
        }
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        let conversationDescription = NSEntityDescription.entity(forEntityName: "Conversation", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Set properties
        self.title = record["title"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        self.isUserCreated = true // just default value, make sure to set after init
        
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
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata; encodedSystemFields not found")
        }
    }
}

extension Conversation: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}


