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

class ConversationModelController: RecordChangeDelegate {
    
    enum SortType {
        case title
        case dateCreated
    }
    
    
    // PROPERTIES:
    
    let sortType: SortType = .dateCreated
    
    var conversations: [Conversation]
    var delegate: ConversationModelControllerDelegate?
    
    // METHODS:
    
    func saveSubscription() {
        // Create and save a silent push subscription in order to be updated:
        let subscriptionID = "cloudkit-conversation-changes"
        let subscriptionSavedKey = "ckSubscriptionSaved"
        
        // Notify for all changes
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(
            recordType: "Conversation",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordUpdate, .firesOnRecordDeletion, .firesOnRecordCreation]
        )
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // silent pushes
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
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
        sortConversations(by: sortType)
        fetchConversations() { (conversations) in
            self.sortConversations(by: self.sortType)
            self.saveToFile(conversations)
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
        switch sortType {
        case .title:
            reverse ? conversations.sort() { $0.title > $1.title } : conversations.sort() { $0.title < $1.title }
        case .dateCreated:
            reverse ? sortByCreationDate(reverse: reverse) : sortByCreationDate(reverse: reverse)
        }
    }
    
    func sortByCreationDate(reverse: Bool = false) {
        conversations.sort() {
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
            self.saveToFile(conversations)
            self.delegate?.updateRecords()
            print("Fetched and saved conversations due to silent push notification.")
        }
    }
    
    // INITIALIZER:
    init() {
        conversations = [Conversation]()
    }
}
