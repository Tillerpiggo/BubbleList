//
//  TestCoreDataStack.swift
//  MagnetHomeworkAppTests
//
//  Created by Tyler Gee on 3/25/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import MagnetHomeworkApp
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
    convenience init() {
        self.init(modelName: "MagnetHomeworkApp")
    }
    
    override init(modelName: String) {
        super.init(modelName: modelName)
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        self.storeContainer = container
    }
}


