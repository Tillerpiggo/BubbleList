//
//  ClassTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/27/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

protocol ClassTableViewControllerDelegate {
    func classDeleted()
    var `class`: Class! { get set }
}

class ClassTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    var delegate: ClassTableViewControllerDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Class> = {
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(Class.dateLastModified), ascending: false)
        fetchRequest.sortDescriptors = [sortByDateLastModified]
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataController.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "MagnetHomeworkApp"
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWithCloud()
        registerAsNotificationDelegate()
        
        tableView.rowHeight = 80
        
        configureNavigationBar()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Add Assignment
        if let destinationViewController = segue.destination.children.first as? AddClassTableViewController, segue.identifier == "AddClass" {
            destinationViewController.delegate = self
            destinationViewController.coreDataController = coreDataController
            destinationViewController.cloudController = cloudController
        } else if let destinationViewController = segue.destination as? AssignmentTableViewController, segue.identifier == "AssignmentTableView" {
            // (didSelectRowAtIndexPath is actually called after prepare(for:)
            guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else { return }
            
            // Dependency injection of class
            let selectedClass = fetchedResultsController.object(at: indexPathForSelectedRow)
            destinationViewController.`class` = selectedClass
            
            // Dependency injection of cloud controller
            destinationViewController.cloudController = cloudController
            destinationViewController.coreDataController = coreDataController
            
            // Set self as delegate to reload rows when necessary (a assignment is added)
            destinationViewController.delegate = self
            
            // Set th title
            destinationViewController.navigationItem.title = selectedClass.name
            
            delegate = destinationViewController
        }
    }
}

// MARK: - Helper Methods

extension ClassTableViewController {
    func updateWithCloud(completion: @escaping (Bool) -> Void = { (didFetchRecords) in }) {
        var didFetchRecords: Bool = false
        
        let zonesDeleted: ([CKRecordZone.ID]) -> Void = { (zoneIDs) in
            if zoneIDs.count > 0 {
                didFetchRecords = true
                
                guard let fetchedObjects = self.fetchedResultsController.fetchedObjects else { return }
                
                // TODO: Implement this later (when you add zones), for now it will just delete everything
                for `class` in fetchedObjects {
                    self.coreDataController.delete(`class`)
                    
                    guard let assignments = `class`.assignments?.array as? [Assignment] else { break }
                    
                    for assignment in assignments {
                        self.coreDataController.delete(assignment)
                    }
                }
            }
        }
        
        // MARK: - Save Changes Block
        
        let saveChanges: ([CKRecord], [CKRecord.ID], DatabaseType) -> Void = { (recordsChanged, recordIDsDeleted, databaseType) in
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("Error fetching classes: \(error)")
            }
            
            print("Number of records changed: \(recordsChanged.count)")
            print("Number of records deleted: \(recordIDsDeleted.count)")
            
            let sortedRecordsChanged = recordsChanged.sorted(by:
            {
                if $0.recordType == "Class" && $1.recordType != "Class" {
                    return false
                } else if $0.recordType == "Assignment" && $1.recordType == "ToDo" {
                    return false
                } else if $0.recordType == "ToDo" && $1.recordType != "ToDo" {
                    //return true
                }
                
                return $0.creationDate! < $1.creationDate!
            })
            
            for record in sortedRecordsChanged {
                print("Record type of changed record: \(record.recordType)")
                
                if let index = self.fetchedResultsController.fetchedObjects?.index(where: { $0.ckRecord.recordID == record.recordID }) {
                    didFetchRecords = true
                    
                    print("Modified class from ClassTableViewController (from Cloud)")
                    
                    self.fetchedResultsController.fetchedObjects?[index].update(withRecord: record)
                    DispatchQueue.main.async { self.coreDataController.save() }
                } else if record.recordType == "Class" {
                    didFetchRecords = true
                    
                    let newClass = Class(fromRecord: record, managedContext: self.coreDataController.managedContext)
                    
                    print("Added class from ClassTableViewController (from Cloud). Title: \(newClass.name ?? "Untitled")")
                    
                    switch databaseType {
                    case .private:
                        newClass.isUserCreated = true
                    case .shared:
                        newClass.isUserCreated = false
                    }
                    
                    DispatchQueue.main.sync { self.coreDataController.save() }
                } else if record.recordType == "Assignment" {
                    didFetchRecords = true
                    
                    print("Added assignment from ClassTableViewController (from Cloud)")
                    
                    if let `class` = self.fetchedResultsController.fetchedObjects?.first(where: { record["owningClass"] as? CKRecord.Reference == CKRecord.Reference(record: $0.ckRecord, action: .deleteSelf) }),
                        let assignments = `class`.assignmentArray {
                        if let assignment = assignments.first(where: { $0.ckRecord.recordID == record.recordID }) {
                            assignment.update(withRecord: record)
                        } else {
                            let assignment = Assignment(fromRecord: record, owningClass: `class`, managedContext: self.coreDataController.managedContext)
                            `class`.addToAssignments(assignment)
                        }
                        
                        `class`.dateLastModified = NSDate()
                    } else {
                        print("ERR: Couldn't find owning class of MagnetHomeworkApp while applying changes.")
                        print("Assignment: \(String(describing: record["text"] as? String))")
                    }
                    
                    DispatchQueue.main.sync { self.coreDataController.save() }
                } else if record.recordType == "ToDo" {
                    didFetchRecords = true
                    
                    print("Added to-do from ClassTableViewController (from Cloud)")
                    
                    if let `class` = self.fetchedResultsController.fetchedObjects?.first(where: { record["classRecordName"] as? String == $0.ckRecord.recordID.recordName }), let assignments = `class`.assignmentArray {
                        
                        print("NUMBER OF ASSIGNMENTS: \(assignments.count)")
                        print("ASSIGNMENT RECORD NAME: \(record["assignmentRecordName"] as? String)")
                        if let assignment = assignments.first(where: { $0.ckRecord.recordID.recordName == record["assignmentRecordName"] as? String }) {
                            if let toDo = assignment.toDo {
                                toDo.update(withRecord: record)
                                print("IS COMPLETED: \(toDo.isCompleted)")
                            } else {
                                assignment.toDo = ToDo(fromRecord: record, managedContext: self.coreDataController.managedContext)
                            }
                        } else {
                            // TODO: figure out what to do... maybe delete the todo?
                        }
                    }
                    
                    DispatchQueue.main.sync { self.coreDataController.save() }
                } else {
                    print("CloudKit.Share received. Do nothing.")
                }
                
                DispatchQueue.main.sync { self.coreDataController.save() }
            }
            
            for recordID in recordIDsDeleted {
                print("Number of objects fetched to be deleted: \(self.fetchedResultsController.fetchedObjects?.count ?? 0)")
                
                if let deletedClass = self.fetchedResultsController.fetchedObjects?.first(where: { $0.ckRecord.recordID == recordID }) {
                    didFetchRecords = true
                    
                    print("Class deleted by ClassTableViewController (from Cloud). Title: \(deletedClass.name ?? "Untitled")")
                    
                    self.coreDataController.delete(deletedClass)
                    
                    guard let deletedAssignments = deletedClass.assignments?.array as? [Assignment] else { return }
                    
                    for assignment in deletedAssignments {
                        self.coreDataController.delete(assignment)
                    }
                    
                    if self.delegate?.class.ckRecord.recordID == recordID {
                        DispatchQueue.main.async { self.delegate?.classDeleted() }
                    }
                    
                } else {
                    for `class` in self.fetchedResultsController.fetchedObjects ?? [] {
                        guard let assignments = `class`.assignments?.array as? [Assignment] else { return }
                        if let deletedAssignment = assignments.first(where: { $0.ckRecord.recordID == recordID }) {
                            didFetchRecords = true
                            
                            print("Assignment deleted by ClassTableViewController (from Cloud)")
                            
                            self.coreDataController.delete(deletedAssignment)
                            `class`.removeFromAssignments(deletedAssignment)
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
        
        print("ClassTableViewCotnroller registered as the notification delegate")
    }
    
    func openClass(withRecordID recordID: CKRecord.ID) {
        if let `class` = self.fetchedResultsController.fetchedObjects?.first(where: { $0.ckRecord.recordID == recordID }),
            let classIndexPath = self.fetchedResultsController.indexPath(forObject: `class`) {
            
            self.tableView.selectRow(at: classIndexPath, animated: true, scrollPosition: .top)
        }
    }
    
    func alertUserOfFailure() {
        let alertController = UIAlertController(title: "Something went wrong!", message: "Check your connection and make sure you have permissions to perform the desired cation.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated:  true, completion: nil)
    }
    
    func configureNavigationBar() {
        // Get gradient
        let blueGradient = UIImage(named: "blueGradient")
        let imageView = UIImageView(image: blueGradient)
        self.navigationItem.titleView = imageView
    }
}

// MARK: - TableView Data Source / Delegate

extension ClassTableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath)
        
        // Get model object
        let `class` = fetchedResultsController.object(at: indexPath)
        
        // Configure cell with model
        cell.textLabel?.text = `class`.name
        cell.detailTextLabel?.text = `class`.latestAssignment
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, fetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
            let deletedClass = fetchedResultsController.object(at: indexPath)
            
            // Delete from cloud
            cloudController.delete([deletedClass], inDatabase: .private) {
                print("Deleted Class!")
                // Delete from core data
                self.coreDataController.delete(deletedClass)
                
                if let deletedAssignments = deletedClass.assignments?.array as? [Assignment] {
                    // Delete all cloud assignments
                    for assignment in deletedAssignments {
                        self.coreDataController.delete(assignment)
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

extension ClassTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case.delete:
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

extension ClassTableViewController: NotificationDelegate {
    func fetchChanges(completion: @escaping (Bool) -> Void) {
        self.updateWithCloud { (didFetchRecords) in
            completion(didFetchRecords)
        }
    }
}

// MARK: - AssignmentTableViewControllerDelegate

extension ClassTableViewController: AssignmentTableViewControllerDelegate {
    func reloadClass(_ `class`: Class) {
        if let classRow = fetchedResultsController.fetchedObjects?.index(where: { $0.ckRecord.recordID == `class`.ckRecord.recordID }) {
            tableView.reloadRows(at: [IndexPath(row: classRow, section: 0)], with: .automatic)
        }
    }
}


// MARK: - Add Class Delegate

extension ClassTableViewController: AddClassTableViewControllerDelegate {
    func addedClass(_ `class`: Class) {
        print("Class added by ClassTableViewController")
        
        // Save change to Core Data
        coreDataController.save()
        
        // Save change to the Cloud
        cloudController.save([`class`], inDatabase: .private, recordChanged: { (updatedRecord) in
            `class`.update(withRecord: updatedRecord)
        }) { (error) in
            guard let error = error as? CKError else { return }
            switch error.code {
            case .requestRateLimited, .zoneBusy, .serviceUnavailable:
                break
            default:
                DispatchQueue.main.async {
                    self.alertUserOfFailure()
                    self.coreDataController.save()
                }
            }
        }
    }
}
