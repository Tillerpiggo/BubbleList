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
    
    // MARK: - API
    func save(_ coreDataUploadables: [CoreDataUploadable]) {
        for coreDataUploadable in coreDataUploadables {
            coreDataUploadable.saveToCoreData(in: coreDataStack.managedContext)
        }
    }
    
    // MARK: - Initializer
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
