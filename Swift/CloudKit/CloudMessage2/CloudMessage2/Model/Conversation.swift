//
//  Conversation.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Conversation: Codable {
    
    // PROPERTIES:
    
    var messages: [Message]
    var creationDate: Date
    var dateLastModified: Date
    var title: String
    
    var ckRecord: CKRecord?
    
    // CODABLE:
    
    enum CodingKeys: CodingKey {
        case messages
        case creationDate
        case dateLastModified
        case title
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(messages, forKey: .messages)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(dateLastModified, forKey: .dateLastModified)
        try container.encode(title, forKey: .title)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        messages = try values.decode([Message].self, forKey: .messages)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
        dateLastModified = try values.decode(Date.self, forKey: .dateLastModified)
        title = try values.decode(String.self, forKey: .title)
        
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        ckRecord = newCKRecord
    }
    
    // INITIALIZERS:
    
    init(withTitle title: String, messages: [Message] = [Message]()) {
        self.title = title
        self.messages = messages
        self.creationDate = Date()
        self.dateLastModified = Date()
        
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord) {
        self.title = record["title"] as! String
        self.messages = [Message]() // Maybe fetch messages or at least first message here
        if let creationDate = record.creationDate {
            self.creationDate = creationDate
        } else {
            self.creationDate = Date()
        }
        
        if let dateLastModified = record.modificationDate {
            self.dateLastModified = dateLastModified
        } else {
            self.dateLastModified = Date()
        }
        
        self.ckRecord = record
    }
}
