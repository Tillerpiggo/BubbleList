//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by Tyler Gee on 8/13/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
  @NSManaged var dateCreated: Date
  @NSManaged var note: Note?
}
