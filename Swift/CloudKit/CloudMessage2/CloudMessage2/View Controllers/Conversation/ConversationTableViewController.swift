//
//  ConversationTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

// MAIN CLASS:

class ConversationTableViewController: UITableViewController {
    
    // PROPERTIES:
    
    var conversations: [Conversation] = [Conversation]()
    var selectedRow: Int? // Necessary because we deselect the row right after it is selected (otherwise it looks ugly)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Conversations:
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Add Conversation
        if let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController, segue.identifier == "AddConversation" {
            destinationViewController.delegate = self
        } else if let destinationViewController = segue.destination as? MessageTableViewController, segue.identifier == "MessageTableView" {
            
            // (didSelectRowAtIndexPath is actually called after prepare(for:)
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            selectedRow = selectedIndexPath.row
            
            // Dependency Injection for selected converation
            let selectedConversation = conversations[selectedRow!]
            
            // Dependency injection of conversation
            destinationViewController.conversation = selectedConversation
            
            // Set the title
            destinationViewController.navigationItem.title = selectedConversation.title
        }
    }
}





// DATA SOURCE AND DELEGATE:

extension ConversationTableViewController {
    
    // DATA SOURCE:
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        
        // Get model object
        let conversation = conversations[indexPath.row]
        
        // Configure cell with model
        cell.textLabel?.text = conversation.title
        cell.detailTextLabel?.text = conversation.messages.first?.text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            conversations.remove(at: indexPath.row)
            
            // Delete from cloud
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // DELEGATE:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
    }
}







// ADD CONVERSATION DELEGATE:

extension ConversationTableViewController: AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation) {
        conversations.append(conversation)
        conversations.sort { $0.dateLastModified > $1.dateLastModified }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}




// MESSAGE DELEGATE:

extension ConversationTableViewController: MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: Conversation) {
        if let selectedRow = selectedRow {
            conversations[selectedRow] = conversation
        }
    }
}
