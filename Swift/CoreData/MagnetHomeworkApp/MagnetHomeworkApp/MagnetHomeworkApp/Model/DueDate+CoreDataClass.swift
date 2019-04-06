//
//  DueDate+CoreDataClass.swift
//  
//
//  Created by Tyler Gee on 3/16/19.
//
//

import Foundation
import CoreData
import CloudKit


public class DueDate: NSManagedObject {
//    var dueDateType: DueDateType {
//        let date = self.date! as Date
//        return DueDateType(withDueDate: date)
//    }
    
    var dueDateType: DueDateType {
        let date = self.date as Date?
        let newDueDateType = DueDateType(withDueDate: date)
        //owningAssignment?.dueDateSection = newDueDateType.section
        //owningAssignment?.updateDueDateSection()
        //let newSection = DueDateType.section(forDueDateType: newDueDateType)
        //owningAssignment?.dueDateSection = newSection
        
        print("OwningAssignment: \(owningAssignment?.dueDateSection)")
        print("Hello")
        return newDueDateType
    }
    
    func dueDateChanged() {
        updateDueDateType()
        updateCKRecordDueDate()
    }
    
    func updateDueDateType() {
        owningAssignment?.dueDateSection = section
    }
    
    func updateCKRecordDueDate() {
        owningAssignment?.ckRecord["dueDate"] = date as CKRecordValue?
    }
    
    @objc var string: String {
        return dueDateType.string
    }
    
    @objc var section: Int {
        let section = dueDateType.section
        //owningAssignment?.dueDateSection = section
        return section
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(withDate date: NSDate?, managedContext: NSManagedObjectContext) {
        let dueDateDescription = NSEntityDescription.entity(forEntityName: "DueDate", in: managedContext)
        super.init(entity: dueDateDescription!, insertInto: managedContext)
        
        self.date = date
        
//        let date = self.date as Date?
//        self.dueDateType = DueDateType(withDueDate: date)
        updateDueDateType()
    }
}
