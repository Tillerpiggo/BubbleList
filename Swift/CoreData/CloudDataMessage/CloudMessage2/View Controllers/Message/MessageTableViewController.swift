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
    func conversationDidChange(to conversation: Conversation, wasModified: Bool)
}

class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    var conversation: Conversation!
    var delegate: MessageTableViewControllerDelegate?
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Multiple lines per message
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // Messages already obtained from core data
        tableView.reloadData()
        
        
        
        // Fetch messages for conversation
        cloudController.fetchRecords(ofType: .message, withParent: conversation) { (records) in
            print("\(records.count) message records fetched from MessageTableViewController.")
            
            // Convert records to messages
            var fetchedMessages = records.map() { Message(fromRecord: $0, managedContext: self.coreDataController.managedContext) }
            fetchedMessages.sort() { $0.timestamp > $1.timestamp }
            
            
            // Delete all messages in the conversation
            for message in self.conversation.messages {
                self.coreDataController.delete(message)
            }
            self.coreDataController.save()
            
            // Add in the new messages
            let messagesToAdd = fetchedMessages.map() { $0.coreDataMessage }
            self.conversation.coreDataConversation.addToMessages(NSSet(array: messagesToAdd))
        
            self.conversation.ckRecord?["latestMessage"] = (self.conversation.messages.first?.text ?? "") as CKRecordValue
            
            self.coreDataController.save()
            
            // Reload table view
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.delegate?.conversationDidChange(to: self.conversation, wasModified: false)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination.childViewControllers.first as? AddMessageTableViewController,
            segue.identifier == "AddMessage" else { return }
        
        destinationViewController.delegate = self
        destinationViewController.coreDataController = coreDataController
        destinationViewController.owningConversation = CKReference(record: conversation.ckRecord!, action: .none)
    }
}

// MARK: - Table View Data Source / Delegate

extension MessageTableViewController {
    
    // MARK: - Date Source
    
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
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Add Message Delegate

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message) {
        
        // Modify model
        conversation.coreDataConversation.addToMessages(message.coreDataMessage)
        conversation.ckRecord?["latestMessage"] = message.text as CKRecordValue
        
        // Save to Core Data
        coreDataController.save()
        
        print("After adding a message, the conversation had \(conversation.messages.count) messages before saving.")
        
        // Save to the Cloud
        cloudController.save(conversation.messages) { print("Succesfully saved messages") }
        
        // Notify delegate
        delegate?.conversationDidChange(to: conversation, wasModified: true)
        
        // Modify table view
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}
