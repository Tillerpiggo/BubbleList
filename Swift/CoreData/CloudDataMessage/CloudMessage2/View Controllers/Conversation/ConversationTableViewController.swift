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

protocol ConversationTableViewControllerDelegate {
    func conversationDidChange(to conversation: CoreDataConversation)
}

class ConversationTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    //var conversations: [Conversation] = [Conversation]()
    var selectedIndexPath: IndexPath? // Necessary because we deselect the row right after it is selected (otherwise it looks ugly)
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    lazy var fetchedResultsController: NSFetchedResultsController<CoreDataConversation> = {
        let fetchRequest: NSFetchRequest<CoreDataConversation> = CoreDataConversation.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(CoreDataConversation.dateLastModified), ascending: false)
        fetchRequest.sortDescriptors = [sortByDateLastModified]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataController.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "CloudMessage"
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWithCloud()
        registerAsNotificationDelegate()
        
        tableView.rowHeight = 80
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Add Conversation
        if let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController, segue.identifier == "AddConversation" {
            destinationViewController.delegate = self
            destinationViewController.coreDataController = coreDataController
            destinationViewController.cloudController = cloudController
        } else if let destinationViewController = segue.destination as? MessageTableViewController, segue.identifier == "MessageTableView" {
            // (didSelectRowAtIndexPath is actually called after prepare(for:)
            guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
            selectedIndexPath = indexPathForSelectedRow
            
            // Dependency injection of conversation
            let selectedConversation = fetchedResultsController.object(at: indexPathForSelectedRow)
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
    
    func updateWithCloud(completion: @escaping (Bool) -> Void = { (didFetchRecords) in }) {
        var didFetchRecords: Bool = false
        
        let zonesDeleted: ([CKRecordZoneID]) -> Void = { (zoneIDs) in
            if zoneIDs.count > 0 {
                didFetchRecords = true
                
                guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else { return }
                
                // TODO: Implement this later (when you add zones), for now it will just delete everything
                for conversation in fetchedObjects {
                    self.coreDataController.delete(conversation)
                    
                    guard let messages = conversation.messages?.array as? [CoreDataMessage] else { break }
                    
                    for message in messages {
                        self.coreDataController.delete(message)
                    }
                }
                self.coreDataController.save()
            }
        }
        
        let saveChanges: ([CKRecord], [CKRecordID]) -> Void = { (recordsChanged, recordIDsDeleted) in
            for record in recordsChanged {
                if let index = self.fetchedResultsController.fetchedObjects?.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    didFetchRecords = true
                    
                    print("Modified conversation from ConversationTableViewController (from Cloud)")
                    
                    self.fetchedResultsController.fetchedObjects?[index].update(withRecord: record)
                    //let changedIndexPath = IndexPath(row: index, section: 0)
                    
                    
                    //self.conversations.sort(by: { $0.dateLastModified > $1.dateLastModified })
                    
                    self.coreDataController.save()
                    
                } else if record.recordType == "Conversation" {
                    didFetchRecords = true
                    
                    print("Added conversation from ConversationTableViewController (from Cloud)")
                    
                    let _ = CoreDataConversation(fromRecord: record, managedContext: self.coreDataController.managedContext)
                    
                    self.coreDataController.save()
                    
                } else if record.recordType == "Message" {
                    didFetchRecords = true
                    
                    print("Added message from ConversationTableViewController (from Cloud)")
                    
                    guard let conversation = self.fetchedResultsController.fetchedObjects?.first(where: { record["owningConversation"] as? CKReference == CKReference(record: $0.ckRecord, action: .none) }),
                        let messages = conversation.messages?.array as? [CoreDataMessage]
                        else { return }
                    
                    if let message = messages.first(where: { $0.ckRecord.recordID == record.recordID }) {
                        message.update(withRecord: record)
                    } else {
                        conversation.addToMessages(CoreDataMessage(fromRecord: record, managedContext: self.coreDataController.managedContext))
                    }
                    
                    conversation.dateLastModified = NSDate()
                    
                    self.coreDataController.save()
                }
            }
            
            for recordID in recordIDsDeleted {
                if let deletedConversation = self.fetchedResultsController.fetchedObjects?.first(where: { $0.ckRecord.recordID == recordID }) {
                    didFetchRecords = true
                    
                    print("Conversation deleted by ConversationTableViewController (from Cloud)")
                    
                    self.coreDataController.delete(deletedConversation)
                    
                    // TODO: Make a messages property of deletedConversation that is of the type [CoreDataMessage]/[Message] instead of NSOrderedSet
                    guard let deletedMessages = deletedConversation.messages?.array as? [CoreDataMessage] else { return }
                    
                    for message in deletedMessages {
                        self.coreDataController.delete(message)
                    }
                    
                    self.coreDataController.save()
                } else {
                    for conversation in self.fetchedResultsController.fetchedObjects ?? [] {
                        guard let messages = conversation.messages?.array as? [CoreDataMessage] else { return }
                        if let deletedMessage = messages.first(where: { $0.ckRecord.recordID == recordID }) {
                            didFetchRecords = true
                            
                            print("Message deleted by ConversationTableViewController (from Cloud)")
                            
                            self.coreDataController.delete(deletedMessage)
                            conversation.removeFromMessages(deletedMessage)
                        }
                    }
                    
                    self.coreDataController.save()
                }
            }
        }
        
        cloudController.fetchDatabaseChanges(zonesDeleted: zonesDeleted, saveChanges: saveChanges) {
            completion(didFetchRecords)
        }
    }
    
    func registerAsNotificationDelegate() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.notificationDelegate = self
        
        print("Conversation Table View Controller registered as the notification delegate")
    }
}





// MARK: - Table View Data Source / Delegate

extension ConversationTableViewController {
    
    // MARK: - Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        
        // Get model object
        let conversation = fetchedResultsController.object(at: indexPath)
        
        // Configure cell with model
        cell.textLabel?.text = conversation.title
        cell.detailTextLabel?.text = conversation.latestMessage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, fetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
            let deletedConversation = fetchedResultsController.object(at: indexPath)
            
            // Delete from core data
            coreDataController.delete(deletedConversation)
            
            if let deletedMessages = deletedConversation.messages?.array as? [CoreDataMessage] {
                // Delete all cloud messages
                for message in deletedMessages {
                    coreDataController.delete(message)
                }
            }
        
            // Delete from cloud
            cloudController.delete([deletedConversation]) {
                print("Deleted Conversation!")
            }
        
            coreDataController.save()
        }
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        
        selectedIndexPath = indexPath
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MessageTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Notification Delegate

extension ConversationTableViewController: NotificationDelegate {
    func fetchChanges(completion: @escaping (Bool) -> Void) {
        self.updateWithCloud { (didFetchRecords) in
            completion(didFetchRecords)
        }
    }
}





// MARK: - Add Conversation Delegate

extension ConversationTableViewController: AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: CoreDataConversation) {
        print("Conversation added by ConversationTableViewController")
        
        // Save change to Core Data
        coreDataController.save()
        
        // Save change to the Cloud
        cloudController.save([conversation], recordChanged: { (updatedRecord) in
            conversation.update(withRecord: updatedRecord)
        })
    }
}




// MARK: - Message Table View Delegate

extension ConversationTableViewController: MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: CoreDataConversation, saveToCloud: Bool) {
        
        if saveToCloud {
            cloudController.save([conversation], recordChanged: { (updatedRecord) in
                conversation.update(withRecord: updatedRecord)
            })
        }
        
        // Save change to Core Data
        DispatchQueue.main.async { self.coreDataController.save() }
    }
}
