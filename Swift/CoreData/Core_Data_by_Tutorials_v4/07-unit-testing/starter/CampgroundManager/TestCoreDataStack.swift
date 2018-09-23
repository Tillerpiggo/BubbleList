//
//  TestCoreDataStack.swift
//  CampgroundManagerTests
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Razeware. All rights reserved.
//

import Foundation
import CampgroundManager
import CoreData

class TestCoreDataStack: CoreDataStack {
  convenience init() {
    self.init(modelName: "CampgroundManager")
  }
  
  override init(modelName: String) {
    super.init(modelName: modelName)
    
    let persistentStoreDescription = NSPersistentStoreDescription()
    persistentStoreDescription.type = NSInMemoryStoreType
    
    let container = NSPersistentContainer(name: modelName)
    container.persistentStoreDescriptions = [persistentStoreDescription]
    
    container.loadPersistentStores() { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unersolved error \(error), \(error.userInfo)")
      }
    }
    
    self.storeContainer = container
  }
}
