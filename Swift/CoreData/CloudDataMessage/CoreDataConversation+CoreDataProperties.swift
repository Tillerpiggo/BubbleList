//
//  Conversation+CoreDataProperties.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataConversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataConversation> {
        return NSFetchRequest<CoreDataConversation>(entityName: "CoreDataConversation")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var dateLastModified: NSDate?
    @NSManaged public var recordMetadata: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var messages: NSOrderedSet?

}

// MARK: Generated accessors for messages
extension CoreDataConversation {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: CoreDataMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: CoreDataMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
