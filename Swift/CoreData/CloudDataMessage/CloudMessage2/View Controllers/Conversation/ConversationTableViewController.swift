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
    func conversationDeleted()
    var conversation: Conversation! { get set }
}

class ConversationTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    var delegate: ConversationTableViewControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Conversation> = {
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(Conversation.dateLastModified), ascending: false)
        fetchRequest.sortDescriptors = [sortByDateLastModified]
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataController.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "CloudMessage"
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
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
            
            // Dependency injection of conversation
            let selectedConversation = fetchedResultsController.object(at: indexPathForSelectedRow)
            destinationViewController.conversation = selectedConversation
            
            // Dependency injection of cloud controller
            destinationViewController.cloudController = cloudController
            destinationViewController.coreDataController = coreDataController
            
            // Set self as delegate to reload rows when necessary (a message is added)
            destinationViewController.delegate = self
            
            // Set the title
            destinationViewController.navigationItem.title = selectedConversation.title
            
            delegate = destinationViewController
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
                    
                    guard let messages = conversation.messages?.array as? [Message] else { break }
                    
                    for message in messages {
                        self.coreDataController.delete(message)
                    }
                }
            }
        }
        
        let saveChanges: ([CKRecord], [CKRecordID], DatabaseType) -> Void = { (recordsChanged, recordIDsDeleted, databaseType) in
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Error fetching conversations: \(error)")
            }
            
            print("Number of records changed: \(recordsChanged.count)")
            print("Number of records deleted: \(recordIDsDeleted.count)")
            
            let sortedRecordsChanged = recordsChanged.sorted(by:
            {
                if $0.recordType == "Conversation" && $1.recordType != "Conversation" {
                    return false
                }
                
                return $0.creationDate! < $1.creationDate!
            })
            
            for record in sortedRecordsChanged {
                print("Record type of changed record: \(record.recordType)")
                
                if let index = self.fetchedResultsController.fetchedObjects?.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    didFetchRecords = true
                    
                    print("Modified conversation from ConversationTableViewController (from Cloud)")
                    
                    self.fetchedResultsController.fetchedObjects?[index].update(withRecord: record)
                    DispatchQueue.main.sync { self.coreDataController.save() }
                } else if record.recordType == "Conversation" {
                    didFetchRecords = true
                    
                    let newConversation = Conversation(fromRecord: record, managedContext: self.coreDataController.managedContext)
                    
                    print("Added conversation from ConversationTableViewController (from Cloud). Title: \(newConversation.title ?? "Untitled")")
                    
                    switch databaseType {
                    case .private:
                        newConversation.isUserCreated = true
                    case .shared:
                        newConversation.isUserCreated = false
                    }
                    
                    DispatchQueue.main.sync { self.coreDataController.save() }
                } else if record.recordType == "Message" {
                    didFetchRecords = true
                    
                    print("Added message from ConversationTableViewController (from Cloud)")
                    
                    if let conversation = self.fetchedResultsController.fetchedObjects?.first(where: { record["owningConversation"] as? CKReference == CKReference(record: $0.ckRecord, action: .deleteSelf) }), let messages = conversation.messageArray {
                        if let message = messages.first(where: { $0.ckRecord.recordID == record.recordID }) {
                            message.update(withRecord: record)
                        } else {
                            let message = Message(fromRecord: record, managedContext: self.coreDataController.managedContext)
                            conversation.addToMessages(message)
                            message.owningConversation = conversation
                        }
                        
                        conversation.dateLastModified = NSDate()
                    } else {
                        print("ERR: Couldn't find owning conversation of CloudMessage while applying changes.")
                        print("Message: \(String(describing: record["text"] as? String))")
                    }
                } else {
                    print("CloudKit.Share recieved. Do nothing.")
                }
                    
                DispatchQueue.main.sync { self.coreDataController.save() }
            }
            
            for recordID in recordIDsDeleted {
                print("number of objects fetched: \(self.fetchedResultsController.fetchedObjects?.count ?? 0)")
                
                if let deletedConversation = self.fetchedResultsController.fetchedObjects?.first(where: { $0.ckRecord.recordID == recordID }) {
                    didFetchRecords = true
                    
                    print("Conversation deleted by ConversationTableViewController (from Cloud). Title: \(deletedConversation.title ?? "Untitled")")
                    
                    self.coreDataController.delete(deletedConversation)
                    
                    // TODO: Make a messages property of deletedConversation that is of the type [Message] instead of NSOrderedSet
                    guard let deletedMessages = deletedConversation.messages?.array as? [Message] else { return }
                    
                    for message in deletedMessages {
                        self.coreDataController.delete(message)
                    }
                    
                    if self.delegate?.conversation.ckRecord.recordID == recordID {
                        DispatchQueue.main.async { self.delegate?.conversationDeleted() }
                    }
                    
                } else {
                    for conversation in self.fetchedResultsController.fetchedObjects ?? [] {
                        guard let messages = conversation.messages?.array as? [Message] else { return }
                        if let deletedMessage = messages.first(where: { $0.ckRecord.recordID == recordID }) {
                            didFetchRecords = true
                            
                            print("Message deleted by ConversationTableViewController (from Cloud)")
                            
                            self.coreDataController.delete(deletedMessage)
                            conversation.removeFromMessages(deletedMessage)
                        }
                    }
                }
            }
            
            DispatchQueue.main.sync {
                self.coreDataController.save()
                self.tableView.reloadData()
            }
        }
        
        cloudController.fetchDatabaseChanges(inDatabase: .private, zonesDeleted: zonesDeleted, saveChanges: saveChanges) {
            completion(didFetchRecords)
            
            self.cloudController.fetchDatabaseChanges(inDatabase: .shared, zonesDeleted: zonesDeleted, saveChanges: saveChanges) {
                completion(didFetchRecords)
            }
        }
    }
    
    func registerAsNotificationDelegate() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.notificationDelegate = self
        
        print("Conversation Table View Controller registered as the notification delegate")
    }
    
    func openConversation(withRecordID recordID: CKRecordID) {
        if let conversation = self.fetchedResultsController.fetchedObjects?.first(where: { $0.ckRecord.recordID == recordID }),
            let conversationIndexPath = self.fetchedResultsController.indexPath(forObject: conversation) {
                self.tableView.selectRow(at: conversationIndexPath, animated: true, scrollPosition: .middle)
        }
    }
    
    func alertUserOfFailure() {
        let alertController = UIAlertController(title: "Something went wrong!", message: "A network failure or another error occurred.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
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
        
            // Delete from cloud
            cloudController.delete([deletedConversation], inDatabase: .private) { // TODO: Make this the shared database sometimes
                print("Deleted Conversation!")
                // Delete from core data
                self.coreDataController.delete(deletedConversation)
                
                if let deletedMessages = deletedConversation.messages?.array as? [Message] {
                    // Delete all cloud messages
                    for message in deletedMessages {
                        self.coreDataController.delete(message)
                    }
                }
                
                DispatchQueue.main.async { self.coreDataController.save() }
            }
        }
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension ConversationTableViewController: NSFetchedResultsControllerDelegate {
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
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
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


// MARK: - MessageTableViewControllerDelegate

extension ConversationTableViewController: MessageTableViewControllerDelegate {
    func reloadConversation(_ conversation: Conversation) {
        if let conversationRow = fetchedResultsController.fetchedObjects?.index(where: { $0.ckRecord.recordID == conversation.ckRecord.recordID }) {
            tableView.reloadRows(at: [IndexPath(row: conversationRow, section: 0)], with: .automatic)
        }
    }
}


// MARK: - Add Conversation Delegate

extension ConversationTableViewController: AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation) {
        print("Conversation added by ConversationTableViewController")
        
        // Save change to Core Data
        coreDataController.save()
        
        // Save change to the Cloud
        cloudController.save([conversation], inDatabase: .private, recordChanged: { (updatedRecord) in
            conversation.update(withRecord: updatedRecord)
        }) { (error) in
            guard let error = error as? CKError else { return }
            switch error.code {
            case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                break
            default:
                self.coreDataController.delete(conversation)
                DispatchQueue.main.async {
                    self.alertUserOfFailure()
                    self.coreDataController.save()
                }
            }
        }
    }
}
