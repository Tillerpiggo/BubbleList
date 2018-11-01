//
//  CoreDataController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
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
    
    func fetchClasses(completion: @escaping ([Class]) -> Void) {
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        
        let asyncFetchRequest = NSAsynchronousFetchRequest<Class>(fetchRequest: fetchRequest) { (result) in
            guard let classes = result.finalResult else { return }
            completion(classes)
        }
        
        do {
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error), \(error.userInfo)")
        }
    }
    
    func fetchMessages(completion: @escaping ([Assignment]) -> Void) {
//        let fetchRequest: NSFetchRequest<Assignment> = Assignment.fetchRequest() as! NSFetchRequest<Assignment>
//
//        let asyncFetchRequest = NSAsynchronousFetchRequest<Assignment>(fetchRequest: fetchRequest) { (result) in
//            guard let messages = result.finalResult else { return }
//            completion(messages)
//        }
//
//        do {
//            try coreDataStack.managedContext.execute(asyncFetchRequest)
//        } catch let error as NSError {
//            print("Could not fetch: \(error), \(error.userInfo)")
//        }
    }
    
    func delete(_ coreDataUploadable: CoreDataUploadable) {
        self.managedContext.delete(coreDataUploadable.coreData)
    }
    
    // MARK: - Initializer
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
