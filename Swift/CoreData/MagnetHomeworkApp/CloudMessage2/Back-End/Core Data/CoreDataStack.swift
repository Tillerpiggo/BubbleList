//
//  FileController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/7/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // MARK: - Properties
    private let modelName: String
    
    // MARK: - Initializer
    init(modelName: String) {
        self.modelName = modelName
    }
    
    
    // MARK: - Stack
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    // MARK: - Methods
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
