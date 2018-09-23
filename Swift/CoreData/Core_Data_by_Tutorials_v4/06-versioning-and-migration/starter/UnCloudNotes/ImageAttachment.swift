//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by Tyler Gee on 8/13/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageAttachment: Attachment {
  @NSManaged var image: UIImage?
  @NSManaged var width: Float
  @NSManaged var height: Float
  @NSManaged var caption: String
}
