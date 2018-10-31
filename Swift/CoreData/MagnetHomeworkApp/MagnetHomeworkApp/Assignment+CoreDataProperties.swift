//
//  Assignment+CoreDataProperties.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var dateLastModified: NSDate?
    @NSManaged public var encodedSystemFields: Data?
    @NSManaged public var text: String?
    @NSManaged public var owningClass: Class?
}
