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
    var expandedIndexPaths = [IndexPath]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Class> = {
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        let sortByDateLastModified = NSSortDescriptor(key: #keyPath(Class.creationDate), ascending: true)
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
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addClassContainerView: UIView!
    @IBOutlet weak var addClassView: UIView!
    @IBOutlet weak var addClassButton: UIButton!
    @IBOutlet weak var addClassTextField: UITextField!
    @IBOutlet weak var addClassText: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWithCloud()
        registerAsNotificationDelegate()
        
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = .backgroundColor
        tableView.separatorColor = .separatorColor
//        tableView.estimatedRowHeight = 0
//        tableView.estimatedSectionFooterHeight = 0
//        tableView.estimatedSectionHeaderHeight = 0
        //tableView.contentInsetAdjustmentBehavior = .automatic
        
        configureNavigationBar()
        configureAddClassView(duration: 0.0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView.isScrollEnabled = true
        
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
//        // GRADIENT
//        let colors: [UIColor] = [UIColor(red: 0.92, green: 0.31, blue: 0.31, alpha: 1),
//                                 UIColor(red: 0.97, green: 0.66, blue: 0.54, alpha: 1)]
//        //navigationController?.navigationBar.setGradientBackground(colors: colors)
        
        navigationController?.navigationBar.barTintColor = .primaryColor
        
        // TINT COLOR
        navigationController?.navigationBar.tintColor = .navigationBarTintColor
        
        // TITLE COLOR
        let textAttributes: [NSAttributedString.Key: UIColor]  = [NSAttributedString.Key.foregroundColor: .navigationBarTintColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ClassTableViewCell else { return }
        
        // Get model object
        let `class` = fetchedResultsController.object(at: indexPath)
        
        // Configure cell with model
        cell.configure(withClass: `class`)
        
        cell.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, fetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
            let deletedClass = fetchedResultsController.object(at: indexPath)
            
            // Delete from core data
            self.coreDataController.delete(deletedClass)
            
            if let deletedAssignments = deletedClass.assignments?.array as? [Assignment] {
                // Delete all cloud assignments
                for assignment in deletedAssignments {
                    self.coreDataController.delete(assignment)
                }
            }
            
            self.coreDataController.save()
            
            // Delete from cloud
            cloudController.delete([deletedClass], inDatabase: .private) {
                print("Deleted Class!")
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 82
//    }
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
//            let deletedClass = self.fetchedResultsController.object(at: indexPath)
//            
//            if self.fetchedResultsController.fetchedObjects?.count == 1 {
//                var frame = CGRect.zero
//                frame.size.height = .leastNormalMagnitude
//                tableView.tableHeaderView = UIView(frame: frame)
//            }
//            
//            // Delete from core data
//            self.coreDataController.delete(deletedClass)
//            self.coreDataController.save()
//            
//            // Delete from cloud
//            self.cloudController.delete([deletedClass], inDatabase: .private) {
//                print("Deleted Class!")
//            }
//        })
//        deleteRowAction.backgroundColor = .destructiveColor
//        
//        return [deleteRowAction]
//    }
    
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
        if let indexPath = fetchedResultsController.indexPath(forObject: `class`) {
            let cell = tableView.cellForRow(at: indexPath) as! ClassTableViewCell
            cell.configure(withClass: `class`)
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
                    //self.alertUserOfFailure()
                    self.coreDataController.save()
                }
            }
        }
    }
}

// MARK: - Add Class View

extension ClassTableViewController: UITextFieldDelegate, UITextDragDelegate {
    @IBAction func addClassButtonPressed(_ sender: Any) {
        addClassButton.isHidden = true
        UIView.animate(withDuration: 0.1, animations: {
            self.addClassView.backgroundColor = .backgroundColor
        })
        
        addClassText.isHidden = true
        addClassTextField.isHidden = false
        
        addClassTextField.becomeFirstResponder()
        addDoneButton()
    }
    
    @IBAction func addClassButtonPressedDown(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addClassView.backgroundColor = UIColor.highlightColor
        })
    }
    
    @IBAction func addClassButtonDraggedOutside(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addClassView.backgroundColor = UIColor.highlightColor
        })
    }
    
    @IBAction func addClassButtonTouchCanceled(_ sender: Any) {
        configureAddClassView(duration: 0.1)
    }
    
    @IBAction func addClassButtonDraggedInside(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.addClassView.backgroundColor = UIColor.highlightColor
        })
    }
    
    @IBAction func addClassButtonDragExited(_ sender: Any) {
        configureAddClassView(duration: 0.1)
    }
    
    func configureAddClassView(duration: TimeInterval) {
        addClassView.layer.cornerRadius = 5
        addClassView.addDropShadow(color: .black, opacity: 0.15, radius: 4)
        addClassTextField.text = ""
        
        self.addClassTextField.isHidden = true
        self.addClassText.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.addClassView.backgroundColor = UIColor.highlightColor
            self.navigationItem.rightBarButtonItem = nil
        }, completion: { (bool) in
            self.addClassButton.isHidden = false
        })
    }
    
    func addDoneButton() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ClassTableViewController.donePressed(sender:))), animated: true)
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        addClassTextField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let name = addClassTextField.text, name != "" {
            saveClass(withName: name)
        }
        
        configureAddClassView(duration: 0.2)
        
        return true
    }
    
//    func textDraggableView(_ textDraggableView: UIView & UITextDraggable, dragSessionDidEnd session: UIDragSession, with operation: UIDropOperation) {
//        addClassTextField.resignFirstResponder()
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addClassTextField.resignFirstResponder()
        return true
    }
    
    private func saveClass(withName name: String) {
        // Create new assignment
        let newClass = Class(withName: name, managedContext: coreDataController.managedContext, zoneID: cloudController.zoneID)
        addedClass(newClass)
    }
}

extension ClassTableViewController: ClassTableViewCellDelegate {
    func expandedClass(_ class: Class) {
        if let indexPath = fetchedResultsController.indexPath(forObject: `class`) {
            expandedIndexPaths.append(indexPath)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func collapsedClass(_ class: Class) {
        guard let indexPath = fetchedResultsController.indexPath(forObject: `class`) else { return }
        if let removedIndex = expandedIndexPaths.firstIndex(where: { $0 == indexPath }) {
            expandedIndexPaths.remove(at: removedIndex)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
