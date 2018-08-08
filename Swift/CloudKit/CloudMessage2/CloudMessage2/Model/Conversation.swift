//
//  Conversation.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

class Conversation: CloudUploadable { // NSObject, NSCoding {
    
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
    var ckRecordSystemFields: NSMutableData
    
    // NSCODING:
    
    /*
    func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
    }
 */
    
    // INITIALIZERS:
    
    init(withTitle title: String, messages: [Message] = [Message]()) {
        // Properties
        self.title = title
        self.messages = messages
        self.creationDate = Date()
        self.dateLastModified = Date()
        self.ckRecordSystemFields = NSMutableData()
        
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
        self.ckRecordSystemFields = NSMutableData()
        
        // CKRecord
        self.ckRecord = record
    }
}
