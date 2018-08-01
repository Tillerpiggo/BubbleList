//
//  Message.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Message: Codable {
    
    // PROPERTIES:
    
    var text: String
    var timestamp: Date
    var formattedTimestamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let formattedTimestamp = dateFormatter.string(from: timestamp)
        return formattedTimestamp
    }
    
    var ckRecord: CKRecord?
    var owningConversation: CKReference?
    
    // CODABLE:
    
    enum CodingKeys: CodingKey {
        case text
        case timestamp
    }
    
    func enocde(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        timestamp = try values.decode(Date.self, forKey: .timestamp)
        
        let newCKRecord = CKRecord(recordType: "Message")
        newCKRecord["text"] = text as CKRecordValue
        ckRecord = newCKRecord
        
        let newCKReference = CKReference(record: newCKRecord, action: .deleteSelf)
        owningConversation = newCKReference
    }
    
    // INTIIALIZERS:
    
    init(fromRecord record: CKRecord) {
        self.text = record["text"] as! String
        self.timestamp = record.creationDate!
        self.owningConversation = record["owningConversation"] as? CKReference
        self.ckRecord = record
    }
    
    init(withText text: String, timestamp: Date, owningConversation: CKReference) {
        self.text = text
        self.timestamp = timestamp
        self.owningConversation = owningConversation
        
        let newCKRecord = CKRecord(recordType: "Message")
        newCKRecord["text"] = text as CKRecordValue
        newCKRecord["owningConversation"] = owningConversation
        ckRecord = newCKRecord
    }
}
