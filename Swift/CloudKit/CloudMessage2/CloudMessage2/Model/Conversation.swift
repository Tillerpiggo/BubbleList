//
//  Conversation.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Conversation: Codable, CloudUploadable {
    
    // PROPERTIES:
    
    var messages: [Message]
    var latestMessage: String {
        // Use the text of the first messasge, if that isn't there, use latestMessage, otherwise, it's blank.
        if let latestMessage = messages.first?.text {
            ckRecord?["latestMessage"] = latestMessage as CKRecordValue
            return latestMessage
        } else if let latestMessage = ckRecord?["latestMessage"] as? String {
            return latestMessage
        } else {
            ckRecord?["latestMessage"] = "" as CKRecordValue
            return ""
        }
    }
    
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
        
        // Properties
        messages = try values.decode([Message].self, forKey: .messages)
        creationDate = try values.decode(Date.self, forKey: .creationDate)
        dateLastModified = try values.decode(Date.self, forKey: .dateLastModified)
        title = try values.decode(String.self, forKey: .title)
        
        // CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
        ckRecord = newCKRecord
    }
    
    // INITIALIZERS:
    
    init(withTitle title: String, messages: [Message] = [Message]()) {
        // Properties
        self.title = title
        self.messages = messages
        self.creationDate = Date()
        self.dateLastModified = Date()
        
        // CKRecord
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        newCKRecord["latestMessage"] = (messages.first?.text as CKRecordValue?) ?? ("" as CKRecordValue)
        self.ckRecord = newCKRecord
    }
    
    init(fromRecord record: CKRecord) {
        // Properties
        self.title = record["title"] as! String
        self.messages = [Message]()
        self.creationDate = record.creationDate ?? Date()
        self.dateLastModified = record.modificationDate ?? Date()
        
        // CKRecord
        self.ckRecord = record
    }
}
