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
    
    func calculateDueDateSection() -> String {
        guard toDo?.isCompleted ?? false == false else {
            return "Completed"
        }
        
        guard let dueDate = dueDate as Date? else {
            return "Unscheduled"
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: Date().firstSecond, to: dueDate.firstSecond)
        
        guard let daysBetween = components.day else {
            return "Unscheduled"
        }
        
        guard dueDate.firstSecond > Date().firstSecond else {
            return "Late"
        }
        
        if daysBetween < 0 {
            return "Late"
        } else if daysBetween == 0 {
            return "Unscheduled"
        } else if daysBetween == 1 {
            return "Due Tomorrow"
        } else if Date().weekday >= 1 && Date().weekday < 6 {
            if daysBetween > 0 && daysBetween < 7 - Date().weekday { // Due Friday or earlier {
                return "Due This Week"
            } else {
                return "Due Later"
            }
        } else if Date().weekday >= 5 {
            if daysBetween > 0 && daysBetween <= 2 {
                return "Due This Monday"
            } else {
                return "Due Later"
            }
        } else {
            return "Due Later"
        }
    }
    
    func calculateDueDateSectionNumber() -> Int {
        switch dueDateSection {
        case "Late": return 0
        case "Unscheduled": return 1
        case "Due Tomorrow": return 2
        case "Due This Week": return 3
        case "Due This Monday": return 3 
        case "Due Later": return 4
        case "Completed": return 5
        default: return -1
        }
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
        updateDueDateSection()
    }
    
    init(withText text: String, managedContext: NSManagedObjectContext, owningClass: Class, zoneID: CKRecordZone.ID, toDoZoneID: CKRecordZone.ID) {
        let assignmentDescription = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        super.init(entity: assignmentDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.owningClass = owningClass
        self.dueDate = nil
        updateDueDateSection()
        
        // Create CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "Assignment", recordID: recordID)
        newCKRecord["text"] = text as CKRecordValue
        newCKRecord["dueDate"] = self.dueDate as CKRecordValue?
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
        self.dueDate = record["dueDate"] as NSDate?
        updateDueDateSection()
        // Remember to set ToDo while retrieving from the Cloud
        
        // Set CKRecord
        self.ckRecord = record
    }
    
    func update(withRecord record: CKRecord) {
        self.text = record["text"] as? String
        self.creationDate = record.creationDate! as NSDate
        self.dateLastModified = record.modificationDate! as NSDate
        self.encodedSystemFields = record.encoded()
        self.dueDate = record["dueDate"] as NSDate?
        updateDueDateSection()
        // Not the responsibility of the Assignment to find the corresponding to-do if it changes
        
        self.ckRecord = record
    }
    
    func updateDueDateSection() {
        self.dueDateSection = calculateDueDateSection()
        self.dueDateSectionNumber = calculateDueDateSectionNumber()
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["text"] = text as CKRecordValue?
            newCKRecord["dueDate"] = dueDate as CKRecordValue?
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
