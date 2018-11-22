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
    
    func previewAssignment() -> Assignment? {
        let compareBlock: (Assignment, Assignment) -> Bool = { (assignment1, assignment2) in
            guard let dueDate1 = assignment1.dueDate else { return false }
            guard let dueDate2 = assignment2.dueDate else { return true }
            let comparisonResult = dueDate1.compare(dueDate2 as Date)

            return comparisonResult == .orderedDescending
        }
        
        let completedAssignments = assignmentArray?.filter({ $0.toDo?.isCompleted ?? false == true })
        
        if let filteredAssignmentArray = completedAssignments?.filter({ $0.dueDate != nil }), filteredAssignmentArray.count > 0 {
            if let previewAssignment = filteredAssignmentArray.max(by: compareBlock) {
                return previewAssignment
            } else {
                return nil
            }
        } else {
            if let previewAssignment = completedAssignments?.max(by: compareBlock) {
                return previewAssignment
            } else {
                return nil
            }
        }
    }
    
    func previewAssignments() -> [Assignment]? {
        let compareBlock: (Assignment, Assignment) -> Bool = {
            return $0.dueDateSectionNumber > $1.dueDateSectionNumber
        }
        
        let completedAssignments = assignmentArray?.filter({ $0.toDo?.isCompleted ?? false != true })
        
        if let mostImportantAssignment = completedAssignments?.max(by: compareBlock) {
            let sectionName = mostImportantAssignment.dueDateSection
            let assignmentsInSection = completedAssignments?.filter { $0.dueDateSection == sectionName }
            
            print("Assignments In Section: \(assignmentsInSection?.map({ $0.text }))\nClass Name: \(self.name)\n")
            return assignmentsInSection?.sorted(by: compareBlock)
        } else {
            return nil
        }
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
        let classDescription = NSEntityDescription.entity(forEntityName: "Class", in: managedContext)
        super.init(entity: classDescription!, insertInto: managedContext)
        
        // Configure CKRecord
        let recordName = UUID().uuidString
        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
        let newCKRecord = CKRecord(recordType: "Class", recordID: recordID)
        newCKRecord["name"] = name as CKRecordValue?
        //newCKRecord["latestAssignment"] = previewAssignment() as CKRecordValue?
        self.ckRecord = newCKRecord
        
        // Set properties
        self.name = name
        self.creationDate = NSDate()
        self.dateLastModified = NSDate()
        self.encodedSystemFields = ckRecord.encoded()
        self.isUserCreated = true
        
        for assignment in assignments {
            self.addToAssignments(assignment)
            assignment.owningClass = self
        }
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
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: encodedSystemFields)
                unarchiver.requiresSecureCoding = true
                let newCKRecord = CKRecord(coder: unarchiver)!
                unarchiver.finishDecoding()
            
                newCKRecord["name"] = name as CKRecordValue?
                //newCKRecord["latestAssignment"] = previewAssignment() as CKRecordValue?
                
                self.ckRecord = newCKRecord
            } catch {
                print("ERROR: Something went wrong with NSKeyedUnarchiver in Class+CoreDataClass")
            }
        } else {
            print("ERROR: Unable to reconstruct CKRecord from metadata (Class); encodedSystemFields not found")
        }
    }
}

extension Class: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
