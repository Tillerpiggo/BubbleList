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


extension CoreDataMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataMessage> {
        return NSFetchRequest<CoreDataMessage>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var owningConversation: CoreDataConversation?

}
