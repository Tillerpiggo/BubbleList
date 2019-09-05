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
import UIKit

public class Assignment: NSManagedObject, CloudUploadable {

    var ckRecord: CKRecord = CKRecord(recordType: "Assignment")
    
    @objc var dueDateString: String {
        guard let dueDate = dueDate else { return "Unscheduled" }
        return dueDate.string
    }
    
    var dueDateType: DueDateType {
        guard let dueDate = dueDate else { return .unscheduled }
        return dueDate.dueDateType
    }
    
//    func calculateDueDateSection() -> String {
////        guard toDo?.isCompleted ?? false == false else {
////            return "Completed"
////        }
////
////        guard let dueDate = dueDate as Date? else {
////            return "Unscheduled"
////        }
////
////        let calendar = Calendar(identifier: .gregorian)
////        let components = calendar.dateComponents([.day], from: Date().firstSecond, to: dueDate.firstSecond)
////
////        guard let daysBetween = components.day else {
////            return "Unscheduled"
////        }
////
////        guard dueDate.firstSecond > Date().firstSecond else {
////            return "Late"
////        }
////
////        if daysBetween < 0 {
////            return "Late"
////        } else if daysBetween == 0 {
////            return "Unscheduled"
////        } else if daysBetween == 1 {
////            return "Due Tomorrow"
////        } else if Date().weekday >= .dueSunday && Date().weekday < .dueThursday {
////            if daysBetween > 0 && daysBetween < 7 - Date().weekday { // Due Friday or earlier {
////                return "Due This Week"
////            } else {
////                return "Due Later"
////            }
////        } else if Date().weekday >= 5 {
////            if daysBetween > 0 && daysBetween <= 2 {
////                return "Due This Monday"
////            } else {
////                return "Due Later"
////            }
////        } else {
////            return "Due Later"
////        }
//
//        return "unimplemented"
//    }
    
//    func calculateDueDateSectionNumber() -> Int {
//        switch dueDateSection {
//        case "Late": return 0
//        case "Unscheduled": return 3
//        case "Due Tomorrow": return 1
//        case "Due This Week": return 2
//        case "Due This Monday": return 3
//        case "Due Later": return 4
//        case "Completed": return 5
//        default:
//            print("DUE DATE SECTION NUMBER NOT FOUND")
//            return -1
//        }
//    }
    
    
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
        //updateDueDateSection()
    }
    
    init(withText text: String, managedContext: NSManagedObjectContext, owningClass: Class, zoneID: CKRecordZone.ID, toDoZoneID: CKRecordZone.ID) {
        let assignmentDescription = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        super.init(entity: assignmentDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.owningClass = owningClass
        self.dueDate = DueDate(withDate: nil, managedContext: managedContext)
        self.isCompleted = false
        self.setIsSynced(to: false)
        //updateDueDateSection()
        
        // Create CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "Assignment", recordID: recordID)
        newCKRecord["text"] = text as CKRecordValue
        newCKRecord["dueDate"] = self.dueDate?.date as CKRecordValue?
        let owningClassReference = CKRecord.Reference(record: owningClass.ckRecord, action: .deleteSelf)
        newCKRecord["owningClass"] = owningClassReference as CKRecordValue
        newCKRecord.setParent(owningClass.ckRecord)
        
        self.ckRecord = newCKRecord
        self.encodedSystemFields = newCKRecord.encoded()
        
        self.toDo = ToDo(isCompleted: false, managedContext: managedContext, assignment: self, zoneID: toDoZoneID)
        //self.dueDate = DueDate(withDate: nil, managedContext: managedContext) *done above*
        
        updateDueDateSection()
    }
    
    init(fromRecord record: CKRecord, owningClass: Class, managedContext: NSManagedObjectContext) {
        let assignmentDescription = NSEntityDescription.entity(forEntityName: "Assignment", in: managedContext)
        super.init(entity: assignmentDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = record["text"] as? String
        self.creationDate = record.creationDate as NSDate? // These shouldn't be nil (because the record should have been saved in the cloud already) but I'm making it not crash for unit testing purposes
        self.dateLastModified = record.modificationDate as NSDate?
        self.encodedSystemFields = record.encoded()
        self.owningClass = owningClass
        self.setIsSynced(to: false)
        
        if let dueDate = dueDate {
            dueDate.date = record["dueDate"] as NSDate?
        } else {
            self.dueDate = DueDate(withDate: record["dueDate"] as NSDate?, managedContext: managedContext)
        }
        
        self.isCompleted = false
        
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
        self.dueDate?.date = record["dueDate"] as NSDate?
        updateDueDateSection()
        // Not the responsibility of the Assignment to find the corresponding to-do if it changes
        
        self.ckRecord = record
        self.isSynced = true // Received from Cloud, so it is synced
    }
    
    func updateDueDateSection() {
        guard let dueDate = dueDate else { return }
        dueDateSection = dueDate.section
    }
    
    // Returns if the corresponding AssignmentTableViewCell should become larger and accomodate a secondary dueDateLabel to specify the exact date it will be or was due
    func shouldDisplayDueDate() -> Bool {
        print("ShouldDisplayDueDate")
        
        guard let dueDate = dueDate else { return false }
        
        switch dueDate.dueDateType {
        case .completed, .dueNextWeek, .dueLater, .late: return true
        default: return false
        }
    }
    
    func generateRecord() {
        if let encodedSystemFields = self.encodedSystemFields {
            let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
            unarchiver.requiresSecureCoding = true
            let newCKRecord = CKRecord(coder: unarchiver)!
            unarchiver.finishDecoding()
            
            newCKRecord["text"] = text as CKRecordValue?
            newCKRecord["dueDate"] = dueDate?.date as CKRecordValue?
            // TODO: Figure out how to have owningClass (or ignore)
            
            self.ckRecord = newCKRecord
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata (Assignment); encodedSystemFields not found")
        }
    }
    
    func setIsSynced(to bool: Bool) {
        isSynced = bool
        
        if isSynced == false {
            owningClass?.isSynced = false
        }
    }
    
}

extension Assignment: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
