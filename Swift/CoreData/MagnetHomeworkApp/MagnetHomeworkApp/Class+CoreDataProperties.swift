//
//  Class+CoreDataProperties.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension Class {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Class> {
        return NSFetchRequest<Class>(entityName: "Class")
    }

    @NSManaged public var name: String?
    @NSManaged public var isUserCreated: Bool
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var dateLastModified: NSDate?
    @NSManaged public var encodedSystemFields: Data?
    @NSManaged public var assignments: NSOrderedSet?

}

// MARK: Generated accessors for assignments
extension Class {

    @objc(insertObject:inAssignmentsAtIndex:)
    @NSManaged public func insertIntoAssignments(_ value: Assignment, at idx: Int)

    @objc(removeObjectFromAssignmentsAtIndex:)
    @NSManaged public func removeFromAssignments(at idx: Int)

    @objc(insertAssignments:atIndexes:)
    @NSManaged public func insertIntoAssignments(_ values: [Assignment], at indexes: NSIndexSet)

    @objc(removeAssignmentsAtIndexes:)
    @NSManaged public func removeFromAssignments(at indexes: NSIndexSet)

    @objc(replaceObjectInAssignmentsAtIndex:withObject:)
    @NSManaged public func replaceAssignments(at idx: Int, with value: Assignment)

    @objc(replaceAssignmentsAtIndexes:withAssignments:)
    @NSManaged public func replaceAssignments(at indexes: NSIndexSet, with values: [Assignment])

    @objc(addAssignmentsObject:)
    @NSManaged public func addToAssignments(_ value: Assignment)

    @objc(removeAssignmentsObject:)
    @NSManaged public func removeFromAssignments(_ value: Assignment)

    @objc(addAssignments:)
    @NSManaged public func addToAssignments(_ values: NSOrderedSet)

    @objc(removeAssignments:)
    @NSManaged public func removeFromAssignments(_ values: NSOrderedSet)

}
