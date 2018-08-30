//
//  Message+CoreDataClass.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CoreDataMessage)
public class CoreDataMessage: NSManagedObject {
    
}

extension CoreDataMessage: CoreDataUploadable {
    var coreData: NSManagedObject {
        return self
    }
}
