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

class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    var conversation: Conversation!
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(Message.timestamp), ascending: false)
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
    
    // MARK: - IBActions
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        // Create a share for the conversation
        let conversationShare = CKShare(rootRecord: conversation.ckRecord)
        
        conversationShare[CKShareTitleKey] = "Share the conversation: \(conversation.title ?? "[Untitled]")" as CKRecordValue?
        conversationShare[CKShareTypeKey] = "Conversation" as CKRecordValue?
        
        // Create a UIShareController to give the user a UI for sharing
        let sharingController = UICloudSharingController(preparationHandler: { (controller, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            self.cloudController.save([self.conversation.ckRecord, conversationShare], inDatabase: .private, recordChanged: { (record) in }) { (error) in
                handler(conversationShare, CKContainer.default(), error)
            }
        })
        
        sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
        sharingController.delegate = self
        
        present(sharingController, animated: true, completion: nil)
    }
    
    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Multiple lines per message
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Core Data will already fetch messages until we optimize it not to
        // TODO: Optimize core data by only fetching and editing the title/dateModified of the conversation, loading/fetching messages later
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let destinationViewController = navigationController.topViewController as? AddMessageTableViewController,
            segue.identifier == "AddMessage" else { return }
        
        destinationViewController.delegate = self
        destinationViewController.coreDataController = coreDataController
        destinationViewController.cloudController = cloudController
        destinationViewController.owningConversation = conversation.ckRecord
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

// MARK: - Add Message Delegate

extension MessageTableViewController: AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message) {
        print("Message added by MessageTableViewController (from user input)")
        
        // Modify model
        conversation.addToMessages(message)
        conversation.ckRecord["latestMessage"] = message.text as CKRecordValue?
        conversation.dateLastModified = NSDate()
        
        // Save to Core Data
        coreDataController.save()
        
        // Save to the Cloud
        cloudController.save([message, self.conversation], inDatabase: .private, recordChanged: { (updatedRecord) in // Needs to be .shared sometimes (when you don't own the conversation)
            if updatedRecord.recordType == "Message" {
                message.update(withRecord: updatedRecord)
            } else {
                self.conversation.update(withRecord: updatedRecord)
            }
        }) { (error) in
            guard let error = error as? CKError else { return }
            switch error.code {
            case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                break
            default:
                self.coreDataController.delete(message)
                DispatchQueue.main.async {
                    self.alertUserOfFailure()
                    self.coreDataController.save()
                }
            }
        }
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
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - UICloudSharingControllerDelegate

extension MessageTableViewController: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        // TODO: Show the user that the operation failed, handle the error
        print("Cloud sharing error: \(error)")
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        // Set the image
        if let thumbnail = UIImage(named: "cloudThumbnail") {
            return UIImagePNGRepresentation(thumbnail)
        } else {
            return nil
        }
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        // Set the title here
        return conversation.title ?? "Untitled Conversation"
    }
}

// MARK: - Helper Methods

extension MessageTableViewController {
    func alertUserOfFailure() {
        let alertController = UIAlertController(title: "Something went wrong!", message: "A network failure or another error occurred.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

