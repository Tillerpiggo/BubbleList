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
    var dueDateType: DueDateType {
        let date = dueDate! as Date
        return DueDateType(withDueDate: date)
    }
}
