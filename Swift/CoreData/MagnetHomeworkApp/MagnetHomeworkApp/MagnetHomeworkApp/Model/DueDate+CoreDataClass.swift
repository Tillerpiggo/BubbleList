//
//  DueDate+CoreDataClass.swift
//  
//
//  Created by Tyler Gee on 3/16/19.
//
//

import Foundation
import CoreData


public class DueDate: NSManagedObject {
//    var dueDateType: DueDateType {
//        let date = self.date! as Date
//        return DueDateType(withDueDate: date)
//    }
    
    var dueDateType: DueDateType {
        let date = self.date as Date?
        let dueDateType = DueDateType(withDueDate: date)
        //owningAssignment?.dueDateSection = section
        return dueDateType
    }
    
    func updateDueDateType() {
        owningAssignment?.dueDateSection = section
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
