//
//  ConversationModelController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

class ConversationModelController {
    
    enum SortType {
        case title
        case creationDate
    }
    
    // PROPERTIES:
    
    var conversations: [Conversation] {
        didSet {
            saveToFile(conversations)
            
            if conversations.count > oldValue.count { // If you added something
                DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = true }
                saveConversations(conversations) {
                    DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
                }
            }
        }
    }
    
    // METHODS:
    
    func loadData(completionHandler: @escaping ([Conversation]) -> Void) {
        loadFromFile()
        sortConversations(by: .title)
        fetchConversations() { (conversations) in
            self.sortConversations(by: .title)
            self.saveToFile(conversations)
            completionHandler(conversations)
        }
    }
    
    func saveData() {
        saveToFile(conversations)
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
        case .creationDate:
            reverse ? sortByCreationDate(reverse: reverse) : sortByCreationDate(reverse: reverse)
        }
    }
    
    func sortByCreationDate(reverse: Bool = false) {
        conversations.sort() {
            var isBefore = false
            
            if let date0 = $0.creationDate, let date1 = $1.creationDate {
                isBefore = date0 < date1
            } else {
                isBefore = false // Put it at the top if it can't decide
            }
            
            if reverse { isBefore = !isBefore }
            
            return isBefore
        }
    }
    
    // INITIALIZER:
    init() {
        conversations = [Conversation]()
    }
}
