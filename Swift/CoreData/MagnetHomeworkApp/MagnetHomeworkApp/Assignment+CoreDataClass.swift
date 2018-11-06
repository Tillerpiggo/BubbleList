//
//  Assignment+CoreDataClass.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class Assignment: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "Assignment")
    
    var formattedCreationDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let formattedTimestamp = dateFormatter.string(from: creationDate! as Date)
        return formattedTimestamp
        
        // TODO: Change to fit prototype
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withText text: String, managedContext: NSManagedObjectContext, owningClass: Class, zoneID: CKRecordZone.ID, toDoZoneID: CKRecordZone.ID) {
        let assignmentDescription = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        super.init(entity: assignmentDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.owningClass = owningClass
        
        // Create CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "Assignment", recordID: recordID)
        newCKRecord["text"] = text as CKRecordValue
        let owningClassReference = CKRecord.Reference(record: owningClass.ckRecord, action: .deleteSelf)
        newCKRecord["owningClass"] = owningClassReference as CKRecordValue
        newCKRecord.setParent(owningClass.ckRecord)
        
        self.ckRecord = newCKRecord
        self.encodedSystemFields = newCKRecord.encoded()
        
        self.toDo = ToDo(isCompleted: false, managedContext: managedContext, assignment: self, zoneID: toDoZoneID)
    }
    
    init(fromRecord record: CKRecord, owningClass: Class, managedContext: NSManagedObjectContext) {
        let assignmentDescription = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        super.init(entity: assignmentDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = record["text"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        self.owningClass = owningClass
        // Remember to set ToDo while retrieving from the Cloud
        
        // Set CKRecord
        self.ckRecord = record
    }
    
    func update(withRecord record: CKRecord) {
        self.text = record["text"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        // Not the responsibility of the Assignment to find the corresponding to-do if it changes
        
        self.ckRecord = record
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["text"] = text as CKRecordValue?
            // TODO: Figure out how to have owningClass (or ignore)
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata (Assignment); encodedSystemFields not found")
        }
    }
}

extension Assignment: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
