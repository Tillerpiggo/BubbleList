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
    
    var dueDateType: DueDateType = .unscheduled
    
    func updateDueDateType() {
        let date = self.date as Date?
        dueDateType = DueDateType(withDueDate: date)
    }
    
    @objc var dueDateSection: Int {
        return 1
        return dueDateType.section
    }
    
    @objc var dueDateString: String {
        return dueDateType.string
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(withDate date: NSDate?, managedContext: NSManagedObjectContext) {
        let dueDateDescription = NSEntityDescription.entity(forEntityName: "DueDate", in: managedContext)
        super.init(entity: dueDateDescription!, insertInto: managedContext)
        
        self.date = date
        
        let date = self.date as Date?
        self.dueDateType = DueDateType(withDueDate: date)
    }
}
