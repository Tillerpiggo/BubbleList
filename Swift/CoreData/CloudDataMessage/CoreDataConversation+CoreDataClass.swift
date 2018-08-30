//
//  Conversation+CoreDataClass.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CoreDataConversation)
public class CoreDataConversation: NSManagedObject {
    
}

extension CoreDataConversation: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
