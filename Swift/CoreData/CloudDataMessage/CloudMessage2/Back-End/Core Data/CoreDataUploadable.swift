//
//  CoreDataUploadable.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/15/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataUploadable {
    func saveToCoreData(in context: NSManagedObjectContext)
}
