//
//  ConversationTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ConversationTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var conversations: [Conversation] = [Conversation]()
    var selectedIndexPath: IndexPath? // Necessary because we deselect the row right after it is selected (otherwise it looks ugly)
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWithCoreData()
        updateWithCloud()
        
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

// MARK: - Helper Methods

extension ConversationTableViewController {
    func updateWithCloudOld() {
        // Get from cloud (probably should show some loading indicator)
        cloudController.fetchRecords(ofType: .conversation) { (records) in
            
            print("\(records.count) conversation records fetched in ConversationTableViewController.")
            
            // Delete all conversations in core data
            for conversation in self.conversations {
                self.coreDataController.delete(conversation)
            }
            self.coreDataController.save()
            
            self.conversations = []
            
            
            // Add in new conversations
            for record in records {
                let newConversation = Conversation(fromRecord: record, managedContext: self.coreDataController.managedContext)
                self.conversations.append(newConversation)
            }
            
            self.conversations.sort() { $0.dateLastModified > $1.dateLastModified }
            
            self.coreDataController.save()
            
            
            // Update view
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    func updateWithCloud() {
        let zonesDeleted: ([CKRecordZoneID]) -> Void = { (zoneIDs) in
            // TODO: Implement this later (when you add zones), for now it will just delete everything
            for conversation in self.conversations {
                self.coreDataController.delete(conversation)
            }
            self.coreDataController.save()
        }
        
        let saveChanges: ([CKRecord], [CKRecordID]) -> Void = { (recordsChanged, recordIDsDeleted) in
            for record in recordsChanged {
                if let index = self.conversations.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    self.conversations[index].update(withRecord: record)
                    DispatchQueue.main.async {
                        let changedIndexPath = IndexPath(row: index, section: 0)
                        self.tableView.reloadRows(at: [changedIndexPath], with: .automatic)
                    }
                } else {
                    self.conversations.append(Conversation(fromRecord: record, managedContext: self.coreDataController.managedContext))
                    DispatchQueue.main.async {
                        let newIndexPath = IndexPath(row: self.conversations.count - 1, section: 0)
                        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                    }
                }
            }
            
            for recordID in recordIDsDeleted {
                if let index = self.conversations.index(where: { $0.ckRecord.recordID == recordID }) {
                    self.conversations.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }
            
            self.coreDataController.save()
        }
        
        cloudController.fetchDatabaseChanges(zonesDeleted: zonesDeleted, saveChanges: saveChanges) { }
    }
    
    func updateWithCoreData() {
        // Initialize Conversations:
        // Get from Core Data
        coreDataController.fetchConversations() { (coreDataConversations) in
            for coreDataConversation in coreDataConversations {
                self.conversations.append(Conversation(fromCoreDataConversation: coreDataConversation))
            }
            self.conversations.sort() { $0.dateLastModified > $1.dateLastModified }
            
            self.coreDataController.save()
            
            DispatchQueue.main.async { self.tableView.reloadData() }
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
            cloudController.delete([deletedConversation]) { }
            
            // Delete from core data
            coreDataController.delete(deletedConversation)
            
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
        cloudController.save([conversation]) { }
        
        // Save change to Core Data
        coreDataController.save()
        
        conversations.append(conversation)
        conversations.sort { $0.dateLastModified > $1.dateLastModified }
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}




// MARK: - Message Table View Delegate

extension ConversationTableViewController: MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: Conversation, wasModified: Bool) {
        
        // Save change to Core Data
        coreDataController.save()
        
        if wasModified {
            // Save change to the cloud
            cloudController.save([conversation]) { }
            
            conversation.coreDataConversation.dateLastModified = NSDate()
        }
        
        if let selectedIndexPath = selectedIndexPath {
            conversations[selectedIndexPath.row] = conversation
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }
}
