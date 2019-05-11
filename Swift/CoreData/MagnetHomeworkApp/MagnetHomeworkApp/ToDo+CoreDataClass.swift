//
//  ToDo+CoreDataClass.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/3/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class ToDo: NSManagedObject, CloudUploadable {
    var ckRecord: CKRecord = CKRecord(recordType: "ToDo")
    //var isSynced: Bool = false // Declared in CoreData instead
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(isCompleted: Bool, managedContext: NSManagedObjectContext, assignment: Assignment, zoneID: CKRecordZone.ID) {
        let toDoDescription = NSEntityDescription.entity(forEntityName: "ToDo", in: managedContext)
        super.init(entity: toDoDescription!, insertInto: managedContext)
        
        // Set properties
        self.isCompleted = isCompleted
        self.assignment = assignment
        
        // Create CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "ToDo", recordID: recordID)
        newCKRecord["isCompleted"] = isCompleted as CKRecordValue
        newCKRecord["assignmentRecordName"] = assignment.ckRecord.recordID.recordName
        newCKRecord["classRecordName"] = assignment.owningClass!.ckRecord.recordID.recordName
        print("INFO: RecordName - \(assignment.ckRecord.recordID.recordName)")
        
        self.ckRecord = newCKRecord
        self.encodedSystemFields = newCKRecord.encoded()
        self.isSynced = false
    }
    
    init(fromRecord record: CKRecord, managedContext: NSManagedObjectContext) {
        let toDoDescription = NSEntityDescription.entity(forEntityName: "ToDo", in: managedContext)
        super.init(entity: toDoDescription!, insertInto: managedContext)
        
        // Set properties
        self.isCompleted = (record["isCompleted"] as? Bool) ?? false
        self.encodedSystemFields = record.encoded()
        
        self.ckRecord = record
        self.isSynced = false // Received from Cloud, so it is synced
    }
    
    func update(withRecord record: CKRecord) {
        self.isCompleted = (record["isCompleted"] as? Bool) ?? false
        self.encodedSystemFields = record.encoded()
        
        self.ckRecord = record
        self.isSynced = true // Received from Cloud, so it is synced
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["isCompleted"] = isCompleted as CKRecordValue
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata (ToDo); encodedSystemFielsd not found")
        }
    }
}

extension ToDo: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
