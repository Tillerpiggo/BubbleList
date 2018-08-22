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
    
    func fetchConversations(completion: @escaping ([CoreDataConversation]) -> Void) {
        let fetchRequest: NSFetchRequest<CoreDataConversation> = CoreDataConversation.fetchRequest()
        
        let asyncFetchRequest = NSAsynchronousFetchRequest<CoreDataConversation>(fetchRequest: fetchRequest) { (result) in
            guard let conversations = result.finalResult else { return }
            completion(conversations)
        }
        
        do {
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error), \(error.userInfo)")
        }
    }
    
    func fetchMessages(completion: @escaping ([CoreDataMessage]) -> Void) {
        let fetchRequest: NSFetchRequest<CoreDataMessage> = CoreDataMessage.fetchRequest()
        
        let asyncFetchRequest = NSAsynchronousFetchRequest<CoreDataMessage>(fetchRequest: fetchRequest) { (result) in
            guard let messages = result.finalResult else { return }
            completion(messages)
        }
        
        do {
            try coreDataStack.managedContext.execute(asyncFetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error), \(error.userInfo)")
        }
    }
    
    func delete(_ coreDataUploadable: CoreDataUploadable) {
        self.managedContext.delete(coreDataUploadable.coreData)
    }
    
    // MARK: - Initializer
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
