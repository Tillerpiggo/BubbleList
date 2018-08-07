//
//  Message.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Message: Codable, CloudUploadable {
    
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
    
    var ckRecord: CKRecord? // remember to set parent property
    
    
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
        
        // TODO: Figure out how to set the parent of the newCKRecord as the owning conversation, maybe fill it in after decoding
        
        let newCKRecord = CKRecord(recordType: "Message")
        newCKRecord["text"] = text as CKRecordValue
        ckRecord = newCKRecord
    }
    
    // INITIALIZERS:
    
    init(fromRecord record: CKRecord) {
        self.text = record["text"] as! String
        self.timestamp = record.creationDate!
        self.ckRecord = record
    }
    
    init(withText text: String, timestamp: Date, owningConversation: CKReference? = nil) {
        // Properties
        self.text = text
        self.timestamp = timestamp
        
        // CKRecord
        let newCKRecord = CKRecord(recordType: "Message")
        newCKRecord["text"] = text as CKRecordValue
        
        if let parentRecord = owningConversation {
            newCKRecord["owningConversation"] = parentRecord
        }
        
        self.ckRecord = newCKRecord
    }
}
