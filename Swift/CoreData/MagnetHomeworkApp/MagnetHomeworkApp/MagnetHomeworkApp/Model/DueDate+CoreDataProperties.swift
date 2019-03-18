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
    
    // Concept obtained from: https://stackoverflow.com/questions/30203562/using-property-observers-on-nsmanaged-vars
    @objc public var date: NSDate? {
        set {
            let key = "date"
            self.willChangeValue(forKey: key)
            self.setPrimitiveValue(newValue, forKey: key)
            self.didChangeValue(forKey: key)
            
            // Every time the user changes the date, update the dueDateType
            updateDueDateType()
        }
        get {
            let key = "date"
            self.willAccessValue(forKey: key)
            let date = self.primitiveValue(forKey: key) as? NSDate
            self.didAccessValue(forKey: key)
            return date
        }
    }
    @NSManaged public var owningAssignment: Assignment?
}
