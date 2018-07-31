//
//  AddConversationDelegate.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

extension ConversationTableViewController: AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation) {
        conversationModelController.conversations.append(conversation)
        conversationModelController.sortConversations(by: conversationModelController.sortType)
        
        var newIndexPath = IndexPath(row: 0, section: 0)
        if let newRow = conversationModelController.conversations.index(where: { $0 === conversation }) {
            newIndexPath.row = newRow
        }
        
        conversationModelController.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}
