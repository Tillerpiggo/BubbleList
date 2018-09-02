//
//  Message+CoreDataProperties.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var owningConversation: Conversation?
    @NSManaged public var encodedSystemFields: Data?
}
