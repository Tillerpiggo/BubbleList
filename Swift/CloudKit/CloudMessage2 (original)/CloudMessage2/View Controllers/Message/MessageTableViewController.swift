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
    var delegate: MessageTableViewControllerDelegate?
    
    var cloudController: CloudController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Multiple lines per message
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Fetch messages for conversation
        cloudController?.fetchRecords(ofType: .message, withParent: conversation) { (records) in
            // Convert records to messages
            let fetchedMessages = records.map() { Message(fromRecord: $0) }
            
            // Modify model
            self.conversation.messages = fetchedMessages
            self.conversation.messages.sort() { $0.timestamp > $1.timestamp }
            self.conversation.ckRecord?["latestMessage"] = (self.conversation.messages.first?.text ?? "") as CKRecordValue
            
            // Reload table view
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.delegate?.conversationDidChange(to: self.conversation)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination.childViewControllers.first as? AddMessageTableViewController,
            segue.identifier == "AddMessage" else { return }
        
        destinationViewController.delegate = self
    }
}

// DATA SOURCE AND DELEGATE:

extension MessageTableViewController {
    
    // DATA SOURCE:
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        // Get model object
        let message = conversation.messages[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.formattedTimestamp
        
        return cell
    }
    
    // DELEGATE:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message) {
        // Make the message belong to this conversation
        message.ckRecord?["owningConversation"] = CKReference(record: conversation.ckRecord!, action: .none)
        
        // Modify model
        conversation.messages.append(message)
        conversation.messages.sort() { $0.timestamp > $1.timestamp }
        conversation.ckRecord?["latestMessage"] = message.text as CKRecordValue
        
        // Save to the Cloud
        cloudController?.save(conversation.messages) { }
        
        // Notify delegate
        delegate?.conversationDidChange(to: conversation)
        
        // Modify table view
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
