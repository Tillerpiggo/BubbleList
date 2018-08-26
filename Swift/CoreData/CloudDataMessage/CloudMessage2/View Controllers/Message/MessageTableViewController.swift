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
        
        // Core Data will already fetch messages until we optimize it not to
        // TODO: Optimize core data by only fetching and editing the title/dateModified of the conversation, loading/fetching messages later
        
        updateWithCloud()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerAsNotificationDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterAsNotificationDelegate()
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = conversation.messages.count
        print("Number of rows in messageTableViewController: \(numberOfRowsInSection)")
        
        return numberOfRowsInSection
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
            didFetchRecords = true
            
            if zoneIDs.count > 0 {
                // TODO: Implement this later (when you add zones), for now it will just delete everything
                for message in self.conversation.messages {
                    self.coreDataController.delete(message)
                }
                self.coreDataController.save()
            }
        }
        
        let saveChanges: ([CKRecord], [CKRecordID]) -> Void = { (recordsChanged, recordIDsDeleted) in
            for record in recordsChanged {
                didFetchRecords = true
                print("New Message RecordID: \(record.recordID)")
                
                if let index = self.conversation.messages.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    self.conversation.messages[index].update(withRecord: record)
                    
                    print("Editing Message: \(self.conversation.messages[index].coreDataMessage), Index: \(index)")
                    
                    let changedIndexPath = IndexPath(row: index, section: 0)
                    
                    DispatchQueue.main.sync {
                        self.tableView.reloadRows(at: [changedIndexPath], with: .automatic)
                        print("Reloaded (edited) row in messageTableViewController!")
                        
                        self.coreDataController.save()
                    }
                } else if record.recordType == "Message" && record["owningConversation"] as? CKReference == CKReference(record: self.conversation.ckRecord, action: .none) {
                    self.conversation.coreDataConversation.addToMessages(Message(fromRecord: record, managedContext: self.coreDataController.managedContext).coreDataMessage)
                    let newIndexPath = IndexPath(row: 0, section: 0)
                    
                    DispatchQueue.main.sync {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                        print("Inserted row in messageTableViewController!")
                        self.tableView.endUpdates()
                        
                        self.coreDataController.save()
                    }
                }
            }
            
            for recordID in recordIDsDeleted {
                didFetchRecords = true
                
                if let index = self.conversation.messages.index(where: { $0.ckRecord.recordID == recordID }) {
                    let message = self.conversation.messages[index]
                    self.conversation.coreDataConversation.removeFromMessages(message.coreDataMessage)
                    
                    DispatchQueue.main.sync {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        print("Deleted row in messageTableViewController!")
                        self.tableView.endUpdates()
                        
                        self.coreDataController.save()
                    }
                 } else if recordID == self.conversation.ckRecord.recordID {
                    for message in self.conversation.messages {
                        self.coreDataController.delete(message)
                    }
                    
                    DispatchQueue.main.async {
                        self.coreDataController.save()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
        
        cloudController.fetchDatabaseChanges(zonesDeleted: zonesDeleted, saveChanges: saveChanges) {
            self.delegate?.conversationDidChange(to: self.conversation, wasModified: false)
            completion(didFetchRecords)
        }
    }
    
    func registerAsNotificationDelegate() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.notificationDelegates.append(self)
        
        print("Number of notification delegates: \(appDelegate?.notificationDelegates.count ?? 0)")
    }
    
    func unregisterAsNotificationDelegate() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.notificationDelegates.removeLast()
        
        print("Number of notification delegates: \(appDelegate?.notificationDelegates.count ?? 0)")
    }
}

// MARK: - Notification Delegate

extension MessageTableViewController: NotificationDelegate {
    func fetchChanges(completion: @escaping (Bool) -> Void) {
        self.updateWithCloud { (didFetchRecords) in
            completion(didFetchRecords)
        }
    }
}

// MARK: - Add Message Delegate

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message) {
        
        // Save to the Cloud
        cloudController.save([message]) { print("Succesfully saved messages") }
        
        // Modify model
        conversation.coreDataConversation.addToMessages(message.coreDataMessage)
        conversation.ckRecord["latestMessage"] = message.text as CKRecordValue
        
        // Save to Core Data
        coreDataController.save()
        
        print("After adding a message, the conversation had \(conversation.messages.count) messages before saving.")
        
        // Notify delegate
        delegate?.conversationDidChange(to: conversation, wasModified: true)
        
        // Modify table view
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}
