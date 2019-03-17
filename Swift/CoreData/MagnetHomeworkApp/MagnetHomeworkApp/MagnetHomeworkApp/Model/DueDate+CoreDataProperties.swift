//
//  DueDate+CoreDataProperties.swift
//  
//
//  Created by Tyler Gee on 3/16/19.
//
//

import Foundation
import CoreData


extension DueDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DueDate> {
        return NSFetchRequest<DueDate>(entityName: "DueDate")
    }

    @NSManaged public var dueDate: NSDate?
    @NSManaged public var owningAssignment: Assignment?

}
