//
//  MessageModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import CloudKit

protocol MessageModelControllerDelegate {
    func didChangeConversation(_ conversation: Conversation)
}

class MessageModelController: RecordChangeDelegate {
    
    // PROPERTIES:
    
    var conversation: Conversation
    var messages: [Message] {
        return conversation.messages
    }
    
    var delegate: MessageModelControllerDelegate?
    
    // SORTING:
    
    func sortMessages(_ reverse: Bool = false) {
        conversation.messages = sortedMessages(conversation.messages, reverse: reverse)
    }
    
    func sortedMessages(_ messages: [Message], reverse: Bool = false) -> [Message] {
        return messages.sorted() {
            return reverse ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp
        }
    }
    
    // METHODS:
    
    func saveData() {
        saveToFile(conversation)
        saveMessages(in: conversation) {
            print("Saved Conversation")
        }
    }
    
    // RECORD CHANGE DELEGATE:
    
    func recordsDidChange() {
        fetchMessages() { (conversation) in
            self.sortMessages()
            self.saveToFile(conversation)
            self.delegate?.didChangeConversation(conversation)
            print("Updated messages due to push notification.")
        }
    }
    
    func recordDeleted(_ recordID: CKRecordID) {
        // Still dunno if I should do anything.
        recordsDidChange()
    }
    
    func recordDidChangeAtZone(_ zoneID: CKRecordZoneID, record: CKRecord) {
        // This is so dumb... I should just rewrite it now.
        recordsDidChange()
    }
    
    func zoneDeleted(_ zoneID: CKRecordZoneID) {
        // Nothing. No use.
        recordsDidChange()
    }
    
    // INITIALIZER:
    
    init(withConversation conversation: Conversation) {
        self.conversation = conversation
    }
}
