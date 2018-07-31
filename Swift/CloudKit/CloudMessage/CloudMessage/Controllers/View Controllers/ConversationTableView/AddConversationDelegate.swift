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
        let newIndexPath = IndexPath(row: conversationModelController.conversations.count, section: 0)
        conversationModelController.conversations.append(conversation)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}
