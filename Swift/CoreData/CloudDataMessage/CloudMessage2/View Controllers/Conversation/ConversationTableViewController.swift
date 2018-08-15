//
//  ConversationTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CoreData

class ConversationTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var conversations: [Conversation] = [Conversation]()
    var selectedIndexPath: IndexPath? // Necessary because we deselect the row right after it is selected (otherwise it looks ugly)
    
    var cloudController: CloudController?
    var coreDataController: CoreDataController!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Conversations:
        // Get from file
        
        // Get from cloud (probably should show some loading indicator)
        cloudController?.fetchRecords(ofType: .conversation) { (records) in
            // Convert to conversations
            let fetchedConversations = records.map() { Conversation(fromRecord: $0, managedContext: self.coreDataController.managedContext) }
            
            // Update model
            self.conversations = fetchedConversations
            
            // Update view
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
        tableView.rowHeight = 60
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Add Conversation
        if let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController, segue.identifier == "AddConversation" {
            destinationViewController.delegate = self
            destinationViewController.coreDataController = coreDataController
        } else if let destinationViewController = segue.destination as? MessageTableViewController, segue.identifier == "MessageTableView" {
            
            // (didSelectRowAtIndexPath is actually called after prepare(for:)
            guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
            selectedIndexPath = indexPathForSelectedRow
            
            // Dependency injection of conversation
            let selectedConversation = conversations[indexPathForSelectedRow.row]
            destinationViewController.conversation = selectedConversation
            
            // Dependency injection of cloud controller
            destinationViewController.cloudController = cloudController
            destinationViewController.coreDataController = coreDataController
            
            // Set up delegate
            destinationViewController.delegate = self
            
            // Set the title
            destinationViewController.navigationItem.title = selectedConversation.title
        }
    }
}





// MARK: - Table View Data Source / Delegate

extension ConversationTableViewController {
    
    // MARK: - Data Source
    
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
        cell.detailTextLabel?.text = conversation.latestMessage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedConversation = conversations.remove(at: indexPath.row)
            
            // Delete from cloud
            cloudController?.delete([deletedConversation]) { }
            
            // Update View
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
    }
}







// MARK: - Add Conversation Delegate

extension ConversationTableViewController: AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation) {
        // Save change to the Cloud
        cloudController?.save([conversation]) { }
        
        conversations.append(conversation)
        conversations.sort { $0.dateLastModified > $1.dateLastModified }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}




// MARK: - Message Table View Delegate

extension ConversationTableViewController: MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: Conversation) {
        // Save change to the Cloud
        cloudController?.save([conversation]) { }
        
        if let selectedIndexPath = selectedIndexPath {
            conversations[selectedIndexPath.row] = conversation
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }
}
