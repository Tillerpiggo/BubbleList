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

class ConversationModelController: RecordChangeDelegate, MessageModelControllerDelegate {
    
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
    
    // METHODS:
    
    func saveSubscription() {
        // Create and save a silent push subscription in order to be updated:
        let conversationSubscriptionID = "cloudkit-conversation-changes"
        let messageSubscriptionID = "cloudkit-message-changes"
        let subscriptionSavedKey = "ckSubscriptionSaved"
        
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
    
    func recordsDidChange() {
        fetchConversations() { (conversations) in
            self.sortConversations(by: self.sortType)
            self.saveToFile(self.conversations)
            self.delegate?.updateRecords()
            print("Fetched and saved conversations due to silent push notification.")
        }
    }
    
    func conversationDidChange(_ conversation: Conversation) {
        if let selectedIndex = selectedIndex {
            conversations[selectedIndex] = conversation
            saveToFile(conversations)
        }
    }
    
    // INITIALIZER:
    init() {
        conversations = [Conversation]()
    }
}
