//
//  TestClass.swift
//  MagnetHomeworkAppTests
//
//  Created by Tyler Gee on 4/2/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation
import CoreData
@testable import MagnetHomeworkApp


// A subclass of Class with an init that doesn't take in zoneID and doesn't initialize the CKRecord.
class TestClass: Class {
    
    init(withName name: String, assignments: [Assignment] = [Assignment](), managedContext: NSManagedObjectContext) {
        // Create entity
        let classDescription = NSEntityDescription.entity(forEntityName: "Class", in: managedContext)
        super.init(entity: classDescription!, insertInto: managedContext)
        
//        // Configure CKRecord
//        let recordName = UUID().uuidString
//        let recordID = CKRecord.ID(recordName: recordName, zoneID: zoneID)
//        let newCKRecord = CKRecord(recordType: "Class", recordID: recordID)
//        newCKRecord["name"] = name as CKRecordValue?
//        //newCKRecord["latestAssignment"] = previewAssignment() as CKRecordValue?
//        self.ckRecord = newCKRecord
        
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
}
