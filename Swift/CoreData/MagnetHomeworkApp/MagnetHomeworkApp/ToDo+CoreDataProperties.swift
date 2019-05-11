//
//  ToDo+CoreDataProperties.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/3/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var isSynced: Bool
    @NSManaged public var assignment: Assignment?
    @NSManaged public var encodedSystemFields: Data?
    @NSManaged public var completionDate: NSDate?
}
