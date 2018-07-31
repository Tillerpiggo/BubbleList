//
//  Message.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

struct Message: Codable {
    var text: String
    var timestamp: Date
    
    init(withRecord record: CKRecord) {
        self.text = record["text"] as! String
        self.timestamp = record["createdAt"] as! Date
    }
}
