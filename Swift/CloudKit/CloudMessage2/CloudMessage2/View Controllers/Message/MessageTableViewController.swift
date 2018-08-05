//
//  MessageTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: Conversation)
}

class MessageTableViewController: UITableViewController {
    
    var conversation: Conversation!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination.childViewControllers.first as? AddMessageTableViewController,
            segue.identifier == "AddMessage" else { return }
        
        destinationViewController.delegate = self
    }
}

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message) {
        if let owningConversation = conversation.ckRecord {
            message.ckRecord?.parent = CKReference(record: owningConversation, action: .deleteSelf)
        }
        
        conversation.messages.append(message)
        conversation.messages.sort { $0.timestamp > $1.timestamp }
        
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
