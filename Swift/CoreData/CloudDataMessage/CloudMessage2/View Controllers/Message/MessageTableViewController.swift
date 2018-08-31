//
//  MessageTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

// Just test stuff today. Then work on the shared database.

import UIKit
import CloudKit
import CoreData

protocol MessageTableViewControllerDelegate {
    func conversationDidChange(to conversation: CoreDataConversation, saveToCloud: Bool)
}

class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    var conversation: CoreDataConversation!
    var delegate: MessageTableViewControllerDelegate?
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    lazy var fetchedResultsController: NSFetchedResultsController<CoreDataMessage> = {
        let fetchRequest: NSFetchRequest<CoreDataMessage> = CoreDataMessage.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(CoreDataMessage.timestamp), ascending: false)
        fetchRequest.sortDescriptors = [sortByDateLastModified]
        fetchRequest.fetchBatchSize = 20
        
        let isInConversationPredicate = NSPredicate(format: "owningConversation == %@", self.conversation)
        fetchRequest.predicate = isInConversationPredicate
        
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
    
    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Multiple lines per message
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Core Data will already fetch messages until we optimize it not to
        // TODO: Optimize core data by only fetching and editing the title/dateModified of the conversation, loading/fetching messages later
        
        // updateWithCloud()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let destinationViewController = navigationController.topViewController as? AddMessageTableViewController,
            segue.identifier == "AddMessage" else { return }
        
        destinationViewController.delegate = self
        destinationViewController.coreDataController = coreDataController
        destinationViewController.cloudController = cloudController
        destinationViewController.owningConversation = CKReference(record: conversation.ckRecord, action: .none)
    }
}

// MARK: - Table View Data Source / Delegate

extension MessageTableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        // Get model object
        let message = fetchedResultsController.object(at: indexPath)
        
        // Configure cell
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.formattedTimestamp
        
        return cell
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
}

// MARK: - Helper Methods

extension MessageTableViewController {
    func updateWithCloud(completion: @escaping (Bool) -> Void = { (didFetchRecords) in }) {
        var didFetchRecords: Bool = false
        
        let zonesDeleted: ([CKRecordZoneID]) -> Void = { (zoneIDs) in
            if zoneIDs.count > 0 {
                didFetchRecords = true
                
                self.coreDataController.delete(self.conversation)
                
                guard let messages = self.fetchedResultsController.fetchedObjects else { return }
                
                // TODO: Implement this later (when you add zones), for now it will just delete everything
                for message in messages {
                    self.coreDataController.delete(message)
                }
                DispatchQueue.main.async { self.coreDataController.save() }
            }
        }
        
        let saveChanges: ([CKRecord], [CKRecordID]) -> Void = { (recordsChanged, recordIDsDeleted) in
            guard let messages = self.fetchedResultsController.fetchedObjects else { return }
            
            for record in recordsChanged {
                if let index = messages.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    didFetchRecords = true
                    
                    print("Message edited by MessageTableViewController (from Cloud)")
                    
                    messages[index].update(withRecord: record)
                    
                    DispatchQueue.main.async { self.coreDataController.save() }
                } else if record.recordType == "Message" && record["owningConversation"] as? CKReference == CKReference(record: self.conversation.ckRecord, action: .none) {
                    didFetchRecords = true
                    
                    print("Message added by MessageTableViewController (from Cloud)")
                    
                    self.conversation.addToMessages(CoreDataMessage(fromRecord: record, managedContext: self.coreDataController.managedContext))
                    
                    DispatchQueue.main.async { self.coreDataController.save() }
                }
            }
            
            for recordID in recordIDsDeleted {
                print("Message deleted by MessageTableViewController (from Cloud)")
                
                if let index = messages.index(where: { $0.ckRecord.recordID == recordID }) {
                    didFetchRecords = true
                    
                    let message = messages[index]
                    self.conversation.removeFromMessages(message)
                    
                    DispatchQueue.main.async { self.coreDataController.save() }
                 } else if recordID == self.conversation.ckRecord.recordID {
                    didFetchRecords = true
                    
                    for message in messages {
                        self.conversation.removeFromMessages(message)
                        self.coreDataController.delete(message)
                    }
                    
                    self.coreDataController.delete(self.conversation)
                    
                    DispatchQueue.main.async {
                        self.coreDataController.save()
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        cloudController.fetchDatabaseChanges(zonesDeleted: zonesDeleted, saveChanges: saveChanges) {
            if didFetchRecords {
                self.conversation.dateLastModified = NSDate()
            }
            
            self.delegate?.conversationDidChange(to: self.conversation, saveToCloud: false)
            completion(didFetchRecords)
        }
    }
}

// MARK: - Add Message Delegate

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: CoreDataMessage) {
        print("Message added by MessageTableViewController (from user input)")
        
        // Modify model
        conversation.addToMessages(message)
        conversation.ckRecord["latestMessage"] = message.text as CKRecordValue?
        conversation.dateLastModified = NSDate()
        
        // Notify delegate
        delegate?.conversationDidChange(to: conversation, saveToCloud: true)
        
        // Save to Core Data
        coreDataController.save()
        
        // Save to the Cloud
        cloudController.save([message], recordChanged: { (updatedRecord) in
            message.update(withRecord: updatedRecord)
        })
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
            tableView.reloadRows(at: [indexPath!], with: .none)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
