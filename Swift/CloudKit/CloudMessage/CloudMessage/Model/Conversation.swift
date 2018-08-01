//
//  Conversation.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Conversation: Codable {
    
    // PROPERTIES:
    
    var users: [User]
    var messages: [Message]
    var creationDate: Date?
    var title: String
    
    var ckRecord: CKRecord?
    
    // CODABLE:
    
    enum CodingKeys: CodingKey {
        case users
        case messages
        case creationDate
        case title
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(users, forKey: .users)
        try container.encode(messages, forKey: .messages)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(title, forKey: .title)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        users = try values.decode([User].self, forKey: .users)
        messages = try values.decode([Message].self, forKey: .messages)
        creationDate = try? values.decode(Date.self, forKey: .creationDate)
        title = try values.decode(String.self, forKey: .title)
        
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        ckRecord = newCKRecord
    }
    
    // INITIALIZERS:
    
    init(withTitle title: String = "", messages: [Message] = [Message](), users: [User] = [User]()) {
        self.title = title
        self.messages = messages
        self.users = users
        self.creationDate = Date()
        
        let newCKRecord = CKRecord(recordType: "Conversation")
        newCKRecord["title"] = title as CKRecordValue
        self.ckRecord = newCKRecord
    }
    
    init(withRecord record: CKRecord) {
        self.title = record["title"] as! String
        self.messages = [Message]()
        self.users = [User]()
        if let creationDate = record.creationDate {
            self.creationDate = creationDate
        } else {
            self.creationDate = Date()
        }
        self.ckRecord = record
    }
}
