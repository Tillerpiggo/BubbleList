//
//  DataMigrationManager.swift
//  UnCloudNotes
//
//  Created by Tyler Gee on 8/13/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class DataMigrationManager {
  let enableMigrations: Bool
  let modelName: String
  let storeName: String = "UnCloudNotesDataModel"
  var stack: CoreDataStack
  
  private var applicationSupportURL: URL {
    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
    return URL(fileURLWithPath: path!)
  }
  
  private lazy var storeURL: URL = {
    let storeFileName = "\(self.storeName).sqlite"
    return URL(fileURLWithPath: storeFileName, relativeTo: self.applicationSupportURL)
  }()
  
  private var storeModel: NSManagedObjectModel? {
    return NSManagedObjectModel.modelVersionsFor(modelNamed: modelName).filter {
      self.store(at: storeURL, isCompatibleWithModel: $0)
    }.first
  }
  
  init(modelNamed modelName: String, enableMigrations: Bool = false) {
    self.modelName = modelName
    self.enableMigrations = enableMigrations
  }
  
  // Helper methods
  private func store(at storeURL: URL, isCompatibleWithModel model: NSManagedObjectModel) -> Bool {
    let storeMetadata = metadataForStoreAtURL(storeURL: storeURL)
    
    return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata)
  }
  
  private func metadataForStoreAtURL(storeURL: URL) -> [String: Any] {
    let metadata: [String: Any]
    do {
      metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    } catch {
      metadata = [:]
      print("Error retrieving metadata for store at URL: \(storeURL): \(error)")
    }
    
    return metadata
  }
}

extension NSManagedObjectModel {
  class var version1: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel")
  }
  
  var isVersion1: Bool {
    return self == type(of: self).version1
  }
  
  class var version2: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v2")
  }
  
  var isVersion2: Bool {
    return self == type(of: self).version2
  }
  
  class var version3: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v3")
  }
  
  var isVersion3: Bool {
    return self == type(of: self).version3
  }
  
  class var version4: NSManagedObjectModel {
    return uncloudNotesModel(named: "UnCloudNotesDataModel v4")
  }
  
  var isVersion4: Bool {
    return self == type(of: self).version3
  }
  
  
  
  
  private class func modelURLs(in modelFolder: String) -> [URL] {
    return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: "\(modelFolder).momd") ?? []
  }
  
  class func modelVersionsFor(modelNamed modelName: String) -> [NSManagedObjectModel] {
    return modelURLs(in: modelName).compactMap(NSManagedObjectModel.init)
  }
  
  class func uncloudNotesModel(named modelName: String) -> NSManagedObjectModel {
    let model = modelURLs(in: "UnCloudNotesDataModel").filter { $0.lastPathComponent == "\(modelName).mom" }.first.flatMap(NSManagedObjectModel.init)
    return model ?? NSManagedObjectModel()
  }
}

func == (firstModel: NSManagedObjectModel, otherModel: NSManagedObjectModel) -> Bool {
  return firstModel.entitiesByName == otherModel.entitiesByName
}
