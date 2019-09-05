//
//  CoreDataUploadable.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataUploadable {
    var coreData: NSManagedObject { get }
}
