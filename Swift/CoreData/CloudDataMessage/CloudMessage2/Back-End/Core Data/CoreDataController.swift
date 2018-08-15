//
//  CoreDataController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/15/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    // MARK: - Properties
    private var coreDataStack: CoreDataStack
    
    var managedContext: NSManagedObjectContext {
        return coreDataStack.managedContext
    }
    
    // MARK: - API
    func save() {
        do {
            try coreDataStack.managedContext.save()
        } catch let error as NSError {
            print("Failed to save with error: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Initializer
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
