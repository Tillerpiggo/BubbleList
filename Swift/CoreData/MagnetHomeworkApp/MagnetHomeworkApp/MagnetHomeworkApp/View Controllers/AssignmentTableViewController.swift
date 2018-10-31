//
//  AddAssignmentTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

protocol AssignmentTableViewControllerDelegate {
    func reloadClass(_ `class`: Class)
}

class AssignmentTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var `class`: Class!
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    var delegate: AssignmentTableViewControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Assignment> = {
        let fetchRequest: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(Assignment.creationDate), ascending: false)
        fetchRequest.sortDescriptors = [sortByDateLastModified]
        fetchRequest.fetchBatchSize = 20 // TODO: May need to adjust
        
        let isInClassPredicate = NSPredicate(format: "owningClass == %@", self.`class`)
        fetchRequest.predicate = isInClassPredicate
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataController.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "\(self.`class`.ckRecord.recordID.recordName)"
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
        // Create a share for the class
        let classShare = CKShare(rootRecord: `class`.ckRecord)
        
        classShare[CKShare.SystemFieldKey.title] = "Share the class: \(`class`.name as CKRecordValue? ?? "[Untitled]" as CKRecordValue)"
        classShare[CKShare.SystemFieldKey.shareType] = "Class" as CKRecordValue?
        
        // Create a UIShareController to give the user a UI for sharing
        let sharingController = UICloudSharingController(preparationHandler: { (controller, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            self.cloudController.save([self.`class`.ckRecord, classShare], inDatabase: .private, recordChanged: { (record) in }) { (error) in
                handler(classShare, CKContainer.default(), error)
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
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let destinationViewController = navigationController.topViewController as? AddAssignmentTableViewController,
            segue.identifier == "AddAssignment" else { return }
        
        destinationViewController.delegate = self
        destinationViewController.coreDataController = coreDataController
        destinationViewController.cloudController = cloudController
        destinationViewController.owningClass = `class`
    }
}

// MARK: - Table View Data Source / Delegate

extension AssignmentTableViewController {
    
    // MARK: - Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count // TODO: optimize to just get number of sections without having to load them
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath)
        
        // Get model object
        let assignment = fetchedResultsController.object(at: indexPath)
        
        // Configure cell
        cell.textLabel?.text = assignment.text
        cell.detailTextLabel?.text = assignment.formattedCreationDate
        
        return cell
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
    }
}

// MARK: - Add Assignment Delegate

extension AssignmentTableViewController: AddAssignmentTableViewControllerDelegate {
    func addedAssignment(_ assignment: Assignment) {
        print("Message added by AssignmentTableViewController (from user input)")
        
        // Modify model
        `class`.addToAssignments(assignment)
        assignment.owningClass = `class`
        `class`.ckRecord["latestAssignment"] = assignment.text as CKRecordValue?
        `class`.dateLastModified = NSDate()
        
        // Save to Core Data
        coreDataController.save()
        
        delegate?.reloadClass(`class`)
        
        let databaseType: DatabaseType = `class`.isUserCreated ? .private : .shared
        
        // Save to the Cloud
        cloudController.save([assignment, self.`class`], inDatabase: databaseType, recordChanged: { (updatedRecord) in
            if updatedRecord.recordType == "Assignment" {
                assignment.update(withRecord: updatedRecord)
            } else {
                self.`class`.update(withRecord: updatedRecord)
            }
        }) { (error) in
            guard let error = error as? CKError else { return }
            switch error.code {
            case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                break
            default:
                self.coreDataController.delete(assignment)
                DispatchQueue.main.async {
                    self.alertUserOfFailure()
                    self.coreDataController.save()
                }
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension AssignmentTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    private func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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

extension AssignmentTableViewController: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        // TODO: Show the user that the operation failed, handle the error
        print("Cloud sharing error: \(error)")
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        // Set the image
        if let thumbnail = UIImage(named: "magnetHomeworkApThumbnail") { // TODO: Add an image to the project
            return thumbnail.pngData()
        } else {
            return nil
        }
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        // Se t the title here
        return `class`.name ?? "Untitled Class"
    }
}

// MARK: - Helper Methods

extension AssignmentTableViewController {
    func alertUserOfFailure() {
        let alertController = UIAlertController(title: "Something went wrong!", message: "Check you connection and make sure you have the proper permissions to perform the desired action.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - ClassTableViewControllerDelegate

extension AssignmentTableViewController: ClassTableViewControllerDelegate {
    func classDeleted() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

