//
//  Class+CoreDataClass.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class Class: NSManagedObject, CloudUploadable {
    
    // MARK: - Properties
    
    var ckRecord: CKRecord = CKRecord(recordType: "Class")
    
    // MARK: - Computed Properties
    
    var latestAssignment: String {
        // Figure out later
        return ""
    }
    
    var assignmentArray: [Assignment]? {
        if let assignmentArray = assignments?.array as? [Assignment] {
            return assignmentArray
        } else {
            return nil
        }
    }
    
    // MARK: - Initializers
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withName name: String, assignments: [Assignment] = [Assignment](), managedContext: NSManagedObjectContext, zoneID: CKRecordZone.ID) {
        // Create entity
        let conversationDescription = NSEntityDescription.entity(forEntityName: "Class", in: managedContext)
        super.init(entity: conversationDescription!, insertInto: managedContext)
        
        // Configure CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "Class", recordID: recordID)
        newCKRecord["name"] = name as CKRecordValue?
        newCKRecord["latestAssignment"] = latestAssignment as CKRecordValue
        self.ckRecord = newCKRecord
        
        // Set properties
        self.name = name
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        // Create entity
        let classDescription = NSEntityDescription.entity(forEntityName: "Class", in: managedContext)
        super.init(entity: classDescription!, insertInto: managedContext)
        
        // Set properties
        self.name = record["name"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        self.isUserCreated = true // just default value, make sure to set after init
        
        // Set CKRecord
        self.ckRecord = record
    }
    
    func update(withRecord record: CKRecord) {
        self.name = record["name"] as? String
        if let creationDate = record.creationDate as NSDate? { self.creationDate = creationDate }
        if let dateLastModified = record.modificationDate as NSDate? { self.dateLastModified = dateLastModified }
        self.encodedSystemFields = record.encoded()
        
        self.ckRecord = record
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["name"] = name as CKRecordValue?
            newCKRecord["latestAssignment"] = latestAssignment as CKRecordValue
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata; encodedSystemFields not found")
        }
    }
}

extension Class: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
