//
//  MessageTableViewController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol MessageTableViewControllerDelegate {
    func didChangeConversation(_ conversation: Conversation)
}

class MessageTableViewController: UITableViewController {
    
    var messageModelController: MessageModelController!
    var delegates: [MessageTableViewControllerDelegate] = [MessageTableViewControllerDelegate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageModelController.sortMessages()
        messageModelController.delegate = self
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        messageModelController.fetchMessages { (conversation) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.messageModelController.sortMessages()
                self.messageModelController.saveToFile(conversation)
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageModelController.saveToFile(messageModelController.conversation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination.childViewControllers.first as? AddMessageTableViewController, segue.identifier == "AddMessage" else { return }
        
        if let conversationRecord = messageModelController.conversation.ckRecord  {
            let conversationReference = CKReference(record: conversationRecord, action: .deleteSelf)
            destinationViewController.conversationReference = conversationReference
        }
        
        destinationViewController.delegate = self
    }
}

extension MessageTableViewController: AddMessageTableViewControllerDelegate, MessageModelControllerDelegate {
    
    func addedMessage(_ message: Message) {
        print("before: \(messageModelController.conversation.messages.count)")
        messageModelController.conversation.messages.append(message)
        print("after: \(messageModelController.conversation.messages.count)")
        
        messageModelController.sortMessages()
        
        var newIndexPath = IndexPath(row: 0, section: 0)
        if let newRow = messageModelController.messages.index(where: { $0 === message }) {
            newIndexPath.row = newRow
            print(newRow)
        }
        
        messageModelController.saveData()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func didChangeConversation(_ conversation: Conversation) {
        for delegate in delegates {
            delegate.didChangeConversation(conversation)
        }
    }
}
