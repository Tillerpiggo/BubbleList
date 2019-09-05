//
//  Assignment+CoreDataClass.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

public class Assignment: NSManagedObject {
    var ckRecord: CKRecord = CKRecord(recordType: "Assignment")
    
    var formattedCreationDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let formattedCreationDate = dateFormatter.string(from: creationDate! as Date)
        return formattedCreationDate
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        generateRecord()
    }
    
    init(withText text: String, timestamp: Date, managedContext: NSManagedObjectContext, owningConversation: CKRecord, zoneID: CKRecordZone.ID) {
        // Create entity
        let messageDescription = NSEntityDescription(forEntityName: "Assignment", in: managedContext)
        super.init(entity: messageDescription!, insertInto: managedContext)
        
        // Set properties
        self.text = text
        self.creationDate = creationDate as NSDate
    }
}
