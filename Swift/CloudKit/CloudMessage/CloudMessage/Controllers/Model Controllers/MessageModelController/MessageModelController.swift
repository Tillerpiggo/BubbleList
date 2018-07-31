//
//  MessageModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class MessageModelController {
    // PROPERTIES:
    
    var conversation: Conversation! {
        didSet {
            // Save to file
            // Do stuff with CloudKit as well
        }
    }
    
    var conversationRecord: CKRecord?
}
