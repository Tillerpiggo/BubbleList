//
//  ConversationModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol ConversationModelControllerDelegate {
    func updateRecords()
}

class ConversationModelController: RecordChangeDelegate, MessageTableViewControllerDelegate {
    
    enum SortType {
        case title
        case dateCreated
    }
    
    // PROPERTIES:
    
    let sortType: SortType = .dateCreated
    
    var conversations: [Conversation]
    var delegate: ConversationModelControllerDelegate?
    
    var selectedIndex: Int? // To keep track of where the selected conversation is in the array
    var selectedConversation: Conversation? {
        if let selectedIndex = selectedIndex {
            return conversations[selectedIndex]
        } else {
            return nil
        }
    }
    
    var localCacheID = "" // Use the zoneName property of a CKRecordZoneID
    // METHODS:
    
    func saveSubscription() {
        // Create and save a silent push subscription in order to be updated:
        let conversationSubscriptionID = "cloudkit-conversation-changes"
        let messageSubscriptionID = "cloudkit-message-changes"
        let subscriptionSavedKey = "ckSubscriptionSaved"
        
        let alreadySubscribed = UserDefaults.standard.bool(forKey: subscriptionSavedKey)
        guard !alreadySubscribed else { return }
        
        // Notify for all changes
        let predicate = NSPredicate(value: true)
        
        let conversationSubscription = CKQuerySubscription(
            recordType: "Conversation",
            predicate: predicate,
            subscriptionID: conversationSubscriptionID,
            options: [.firesOnRecordUpdate, .firesOnRecordDeletion, .firesOnRecordCreation]
        )
        let messageSubscription = CKQuerySubscription(
            recordType: "Message",
            predicate: predicate,
            subscriptionID: messageSubscriptionID,
            options: [.firesOnRecordUpdate, .firesOnRecordDeletion, .firesOnRecordCreation]
        )
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // silent pushes
        
        conversationSubscription.notificationInfo = notificationInfo
        messageSubscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [conversationSubscription, messageSubscription], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            guard error == nil else { 
                return
            }
            
            UserDefaults.standard.set(true, forKey: subscriptionSavedKey)
            print("subscribed")
        }
        operation.qualityOfService = .utility
        
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        database.add(operation)
    }
    
    func loadData(completionHandler: @escaping ([Conversation]) -> Void) {
        loadFromFile()
        conversations = self.sortedConversations(conversations, by: sortType)
        fetchConversations() { (conversations) in
            self.conversations = self.sortedConversations(conversations, by: self.sortType)
            self.saveToFile(self.conversations)
            completionHandler(conversations)
        }
    }
    
    func saveData() {
        saveToFile(conversations)
        saveConversations(conversations) {
            print("Successfully Saved Conversations.")
        }
    }
    
    func delete(at index: Int, completionHandler: @escaping () -> Void) {
        let conversation = conversations.remove(at: index)
        saveToFile(conversations)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        deleteConversations([conversation]) {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completionHandler()
            }
        }
    }
    
    func sortConversations(by sortType: SortType, reverse: Bool = false) {
        conversations = sortedConversations(conversations, by: sortType, reverse: reverse)
    }
    
    func sortedConversations(_ conversations: [Conversation], by sortType: SortType, reverse: Bool = false) -> [Conversation] {
        switch sortType {
        case .title:
            return reverse ? conversations.sorted() { $0.title > $1.title } : conversations.sorted() { $0.title < $1.title }
        case .dateCreated:
            return sortedConversationsByCreationDate(conversations, reverse: reverse)
        }
    }
    
    func sortedConversationsByCreationDate(_ conversations: [Conversation], reverse: Bool = false) -> [Conversation] {
        return conversations.sorted() {
            var isBefore = false
            
            if let date0 = $0.creationDate, let date1 = $1.creationDate {
                isBefore = date0 > date1
            } else {
                isBefore = true // Put it at the top if it can't decide
            }
            
            if reverse { isBefore = !isBefore }
            
            return isBefore
        }
    }
    
    func mergeConversations(_ oldConversations: [Conversation], with newConversations: [Conversation]) -> [Conversation] {
        // Merge a new set of conversations with new conversations
        
        // Merged conversations starts out as the new conversations, and a bit of info is
        // Filled in by the old conversations, such as messages
        var mergedConversations = sortedConversations(newConversations, by: .dateCreated, reverse: false)
        let oldConversations = sortedConversations(oldConversations, by: .dateCreated, reverse: false)
        
        if oldConversations.count == 0 {
            print("Merged Conversations: \(mergedConversations.last?.messages.first?.text ?? "No message found")")
            return mergedConversations
        } else if newConversations.count == 0 {
            return oldConversations
        }
        
        // print("OldConversations: \(oldConversations.count)")
        // print("NewConversations: \(newConversations.count)")
        
        if oldConversations.count == newConversations.count { // Something was edited
            for (index, mergedConversation) in mergedConversations.enumerated() {
                // Add messages (because you don't fetch messages from the Cloud, just conversations)
                mergedConversation.messages = oldConversations[index].messages
            }
        } else if oldConversations.count < newConversations.count { // Some thing(s) were added
            // Won't iterate through the newly added conversations
            for (index, oldConversation) in oldConversations.enumerated() {
                mergedConversations[index].messages = oldConversation.messages
            }
        } else if oldConversations.count > newConversations.count { // Some thing(s) were deleted
            // Determine what was deleted somehow - maybe request that from the server?
            // Then delete that index from oldConversations and fill in message data
            
            // Do nothing... yet
        }
        
        return mergedConversations
    }
    
    // DELEGATES:
    
    /*
    func recordsDidChange() {
        fetchConversations() { (conversations) in
            self.sortConversations(by: self.sortType)
            self.saveToFile(self.conversations)
            self.delegate?.updateRecords()
            print("Fetched and saved conversations due to silent push notification.")
        }
    }
 */
    func recordDidChangeAtZone(_ zoneID: CKRecordZoneID, record: CKRecord) {
        localCacheID = "\(zoneID.zoneName)"
        loadFromFile()
        
        if let changedIndex = conversations.index(where: { $0.ckRecord?.recordID == record.recordID }) {
            conversations[changedIndex] = Conversation(fromRecord: record)
            sortConversations(by: sortType)
            saveToFile(conversations)
        } else {
            print("was unable to edit conversation at zone: \(zoneID.zoneName)")
        }
    }
    
    func recordDeleted(_ recordID: CKRecordID) {
        localCacheID = "\(recordID.zoneID.zoneName)"
        loadFromFile()
        
        if let changedIndex = conversations.index(where: { $0.ckRecord?.recordID == recordID}) {
            conversations.remove(at: changedIndex)
            sortConversations(by: sortType)
            saveToFile(conversations)
            self.delegate?.updateRecords()
        } else {
            print("was unable to edit conversation at zone: \(recordID.zoneID.zoneName)")
        }
    }
    
    func zoneDeleted(_ zoneID: CKRecordZoneID) {
        localCacheID = "\(zoneID.zoneName)"
        clearDirectory(named: localCacheID)
    }
    
    func didChangeConversation(_ conversation: Conversation) {
        if let selectedIndex = selectedIndex {
            conversations[selectedIndex] = conversation
            saveToFile(conversations)
            self.delegate?.updateRecords()
        }
    }
    
    // INITIALIZER:
    
    init() {
        conversations = [Conversation]()
    }
}
