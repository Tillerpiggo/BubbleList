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

protocol CoreDataTableViewController: UITableViewDelegate, UITableViewDataSource {
    var predicate: NSPredicate { get }
    var sortDescriptors: [NSSortDescriptor] { get }
    
}

class AssignmentViewController: ToDoTableViewController {
    
    // MARK: - Properties
    
    var `class`: Class!
    
    
    var delegate: AssignmentTableViewControllerDelegate?
    
    override var sectionNameKeyPath: String { return #keyPath(Assignment.dueDateString) }
    
    override var sortDescriptors: [NSSortDescriptor] {
        let sortBySectionNumber = NSSortDescriptor(key: #keyPath(Assignment.dueDateSection), ascending: true)
        let sortByDueDate = NSSortDescriptor(key: #keyPath(Assignment.dueDate.date), ascending: true)
        let sortByCreationDate = NSSortDescriptor(key: #keyPath(Assignment.creationDate), ascending: true)
        let sortByCompletionDate = NSSortDescriptor(key: #keyPath(Assignment.toDo.completionDate), ascending: false)
        
        return [sortBySectionNumber, sortByCompletionDate, sortByDueDate, sortByCreationDate]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    override func predicate() -> NSPredicate {
        return NSPredicate(format: "owningClass == %@", self.`class`) // old: "owningClass == %@ && isCompleted == false" ( I removed the last thing )
    }
    
    override func cacheName() -> String? {
        return nil
        return `class`.ckRecord.recordID.recordName
    }
    
    func fetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }
    
//    // MARK: - IBOutlets
//
//    @IBOutlet weak var addAssignmentView: UIView!
//    @IBOutlet weak var addAssignmentContainerView: UIView!
//    @IBOutlet weak var addAssignmentButton: UIButton!
//    @IBOutlet weak var addAssignmentTextField: UITextField!
//    @IBOutlet weak var addAssignmentText: UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //tableView.reloadData()
        //print("HiddenSections: \(hiddenSections)")
    }
    
    override func saveObject(text: String) {
        // Create new assignment
        let zoneID = `class`.ckRecord.recordID.zoneID
        let newAssignment = Assignment(withText: text, managedContext: coreDataController.managedContext, owningClass: `class`, zoneID: zoneID, toDoZoneID: cloudController.zoneID)
        addedAssignment(newAssignment)
        
        //updateHeaderView()
    }
    
    // Adds and removes the done button when the add object button does stuff
    
    override func removeDoneButton() {
        self.navigationItem.setRightBarButtonItems([self.navigationItem.rightBarButtonItems!.last!], animated: true)
    }
    
    override func addDoneButton() {
        let newBarButtonItems: [UIBarButtonItem]? = [doneButton, self.navigationItem.rightBarButtonItem!]
        
        self.navigationItem.setRightBarButtonItems(newBarButtonItems, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
            let destinationViewController = navigationController.topViewController as? ScheduleTableViewController,
            let selectedAssignment = self.selectedAssignment,
            segue.identifier == "ScheduleTableView" else { return }
        
        destinationViewController.assignment = selectedAssignment
        destinationViewController.coreDataController = coreDataController
        destinationViewController.delegate = self
        
        navigationController.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
        navigationController.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
        navigationController.navigationBar.titleTextAttributes = self.navigationController?.navigationBar.titleTextAttributes
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell
        
        return cell
    }
}

//// MARK: - Table View Data Source / Delegate
//
extension AssignmentViewController {
//
//    // MARK: - Data Source
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        guard let sections = fetchedResultsController.sections else {
//            return 0
//        }
//
//        return sections.count // TODO: optimize to just get number of sections without having to load them
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionInfo = fetchedResultsController.sections?[section] else {
//            return 0
//        }
//
//        return sectionInfo.numberOfObjects
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = cell as? AssignmentTableViewCell else { return }
//
//        // Get model object
//        let assignment = fetchedResultsController.object(at: indexPath)
//
//        // Configure cell
//        cell.configure(withAssignment: assignment)
//        cell.delegate = self
//        cell.separatorView.isHidden = true //To remove separator view
////        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
////        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
////        } else if indexPath.row == 0 {
////        } else {
////            cell.separatorView.isHidden = true //To remove separator view
////        }
//
//        let selectedBackgroundView = UIView()
//        selectedBackgroundView.backgroundColor = UIColor.highlightColor
//        cell.selectedBackgroundView = selectedBackgroundView
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return titleForHeader(inSection: section)
//    }
//
//    func titleForHeader(inSection section: Int) -> String {
//        guard let sectionInfo = fetchedResultsController.sections?[section] else {
//            return ""
//        }
//
//        //let numberOfRows = tableView.numberOfRows(inSection: section)
//        return "\(sectionInfo.name)".uppercased()//" (\(numberOfRows))"
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let assignment = fetchedResultsController.object(at: indexPath)
//
//        if hiddenSections.contains(indexPath.section) {
//            return 0
//        }
//
//        let title = self.tableView(tableView, titleForHeaderInSection: indexPath.section)
//        let sectionIsCompleted = title?.contains("Completed") ?? false
//
//        if let dueDate = assignment.dueDate as Date?, dueDate != Date.tomorrow, !sectionIsCompleted {
//            return 60
//        } else {
//            return 44
//        }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //return nil

        let title = titleForHeader(inSection: section)

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AssignmentHeaderFooterView") as! AssignmentHeaderFooterView
        headerView.delegate = self
        headerView.section = section

        headerView.titleLabel.text = title
        //headerView.backgroundColorView.backgroundColor = UIColor.color(fromSection: title)
        headerView.titleLabel.textColor = UIColor.color(fromSection: title)
        //headerView.translatesAutoresizingMaskIntoConstraints = false

        if title.contains("Completed") && isCompletedHidden {
            headerView.isExpanded = false
            headerView.updateShowHideButton()
            isCompletedHidden = true
            if !hiddenSections.contains(section) { hiddenSections.append(section) }
            //print("HiddenSections: \(hiddenSections)")


            //tableView.beginUpdates()
            //tableView.endUpdates()
        }

        return headerView
    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 34
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
//
//    // MARK: - Delegate
//
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let completeAction = UIContextualAction(style: .normal, title: "Complete", handler: { action, indexPath, completionHandler in
//            self.perform(Selector("AssignmentViewController.buttonPressed(assignment:)"))
//
//            completionHandler(true)
//        })
//
//        completeAction.backgroundColor = .nothingDueColor
//        completeAction.image = UIImage(named: "greenCheckmark")!.resized(to: CGSize(width: 32, height: 32))
//
//        return UISwipeActionsConfiguration(actions: [completeAction])
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let scheduleAction = UIContextualAction(style: .normal, title: "Schedule", handler: { _, _, completionHandler in
//            self.selectedAssignment = self.fetchedResultsController.object(at: indexPath)
//            self.performSegue(withIdentifier: "ScheduleTableView", sender: self)
//        })
//
//        scheduleAction.image = UIImage(named: "thiccCalendarGlyph")!.resized(to: CGSize(width: 32, height: 32))
//        scheduleAction.backgroundColor = UIColor(hue: 50, saturation: 70, brightness: 80, alpha: 1.0)
//
//        return UISwipeActionsConfiguration(actions: [scheduleAction])
//    }
//
////    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
////        let scheduleRowAction = UITableViewRowAction(style: .default, title: "Schedule", handler: { (action, indexpath) in
////            self.selectedAssignment = self.fetchedResultsController.object(at: indexPath)
////            self.performSegue(withIdentifier: "ScheduleTableView", sender: self)
////        })
////
////        let deleteRowAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
////            let deletedAssignment = self.fetchedResultsController.object(at: indexPath)
////
////            if self.fetchedResultsController.fetchedObjects?.count == 1 {
////                var frame = CGRect.zero
////                frame.size.height = 0
////                tableView.tableHeaderView = UIView(frame: frame)
////
//////                UIView.animate(withDuration: 0.0, animations: {
//////                }, completion: { (bool) in
//////                    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
//////                        tableView.tableHeaderView = UIView(frame:frame)
//////                    })
//////                })
////            }
////
////            // Delete from core data
////            self.coreDataController.delete(deletedAssignment)
////            self.coreDataController.save()
////
////            // Delete from cloud
////            self.cloudController.delete([deletedAssignment], inDatabase: .private) {
////                print("Deleted Class!")
////            }
////        })
////        deleteRowAction.backgroundColor = .destructiveColor
////
////        return [deleteRowAction]
////    }
//
//    // MARK: - Delegate
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.selectedAssignment = self.fetchedResultsController.object(at: indexPath)
//
//        tableView.beginUpdates()
//        tableView.deselectRow(at: indexPath, animated: true)
//        tableView.endUpdates()
//    }
}

// MARK: - Add Assignment Delegate

extension AssignmentViewController: AddAssignmentTableViewControllerDelegate {
    func addedAssignment(_ assignment: Assignment) {
        print("Assignment added by AssignmentTableViewController (from user input)")
        
        // Modify model
        `class`.addToAssignments(assignment)
        assignment.owningClass = `class`
        `class`.ckRecord["latestAssignment"] = assignment.text as CKRecordValue?
        `class`.dateLastModified = NSDate()
        
        // Save to Core Data
        coreDataController.save()
        
        delegate?.reloadClass(`class`)
        
        let databaseType: DatabaseType = `class`.isUserCreated ? .private : .shared
        
        print("ClassNameToSave: \(self.`class`.ckRecord["name"] as String?)")
        
        if databaseType == .private {
            // Save to the Cloud
            cloudController.save([assignment, assignment.toDo!, self.`class`], inDatabase: databaseType, recordChanged: { (updatedRecord) in
                if updatedRecord.recordType == "Assignment" {
                    assignment.update(withRecord: updatedRecord)
                } else if updatedRecord.recordType == "ToDo" {
                    assignment.toDo?.update(withRecord: updatedRecord)
                } else {
                    self.`class`.update(withRecord: updatedRecord)
                }
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
        } else {
            // Save to the Cloud
            cloudController.save([assignment.toDo!], inDatabase: .private, recordChanged: { (updatedRecord) in
                assignment.toDo?.update(withRecord: updatedRecord)
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
            
            // Save to the Cloud
            cloudController.save([assignment, self.`class`], inDatabase: databaseType, recordChanged: { (updatedRecord) in
                if updatedRecord.recordType == "Assignment" {
                    assignment.update(withRecord: updatedRecord)
                } else if updatedRecord.recordType == "ToDo" {
                    assignment.toDo?.update(withRecord: updatedRecord)
                } else {
                    self.`class`.update(withRecord: updatedRecord)
                }
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
}

// MARK: - NSFetchedResultsControllerDelegate

//extension AssignmentViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//        print("BEGAN UPDATES")
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .automatic)
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .top)
//            //tableView.scrollToRow(at: newIndexPath!, at: .none, animated: true)
//            //DispatchQueue.main.async { self.reloadHeader(forSection: newIndexPath!.section) }
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            //DispatchQueue.main.async { self.reloadHeader(forSection: indexPath!.section) }
//        case .move:
//            print("Current Section has \(tableView.numberOfRows(inSection: indexPath!.section)) rows")
//            print("New Section has \(tableView.numberOfRows(inSection: newIndexPath!.section)) rows")
//
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//            break
//
//            if tableView.numberOfSections == 1 && tableView.numberOfRows(inSection: 0) == 1 && self.tableView(tableView, titleForHeaderInSection: indexPath!.section) != "Completed" {
//                break
//            }
//
//            if tableView.numberOfRows(inSection: indexPath!.section) <= 1 || tableView.numberOfRows(inSection: newIndexPath!.section) <= 1 {
//                tableView.reloadRows(at: [indexPath!], with: .automatic)
//            } else {
//                //tableView.reloadRows(at: [indexPath!], with: .automatic)
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
//            }
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .delete:
//            for (index, hiddenSection) in hiddenSections.enumerated() where hiddenSection >= sectionIndex {
//                hiddenSections[index] -= 1
//                print("HiddenSections: \(hiddenSections)")
//                if let section = tableView.headerView(forSection: hiddenSection) as? AssignmentHeaderFooterView {
//                    section.section? -= 1
//                }
//            }
//            tableView.deleteSections([sectionIndex], with: .fade)
//        case .insert:
//            for (index, hiddenSection) in hiddenSections.enumerated() where hiddenSection >= sectionIndex {
//                hiddenSections[index] += 1
//                print("HiddenSections: \(hiddenSections)")
//                if let section = tableView.headerView(forSection: hiddenSection) as? AssignmentHeaderFooterView {
//                    section.section? += 1
//                }
//            }
//
//            self.tableView.insertSections([sectionIndex], with: .fade)
//
//
//        default:
//            break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//        print("ENDED UPDATES")
//    }
//}

// MARK: - UICloudSharingControllerDelegate

extension AssignmentViewController: UICloudSharingControllerDelegate {
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
        // Set the title here
        return `class`.name ?? "Untitled Class"
    }
}

// MARK: - Helper Methods

extension AssignmentViewController {
    func alertUserOfFailure() {
        let alertController = UIAlertController(title: "Something went wrong!", message: "Check you connection and make sure you have the proper permissions to perform the desired action.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateHeaderView() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            var frame = CGRect.zero
            frame.size.height = 0
            tableView.tableHeaderView = UIView(frame: frame)
        } else {
            var frame = CGRect.zero
            frame.size.height = 0
            tableView.tableHeaderView = UIView(frame: frame)
        }
    }
    
    func reloadHeader(forSection section: Int) {
        let header = tableView.headerView(forSection: section)
        header?.textLabel?.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercased()
    }
}

// MARK: - ClassTableViewControllerDelegate

extension AssignmentViewController: ClassTableViewControllerDelegate {
    func classDeleted() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AssignmentTableViewCellDelegate

extension AssignmentViewController {
    @objc override func buttonPressed(assignment: Assignment) -> Bool {
        let bool = buttonPressed(assignment: assignment)
        delegate?.reloadClass(`class`)
        return bool
    }
}

//extension AssignmentViewController: AssignmentHeaderFooterCellDelegate {
//    func showHideButtonPressed(isExpanded: Bool, forSection section: Int) {
//        if !isExpanded && !hiddenSections.contains(section) {
//            hiddenSections.append(section)
//            print("HiddenSections: \(hiddenSections)")
//        } else if !isExpanded && hiddenSections.contains(section) {have
//            // Do nothing
//        } else {
//            hiddenSections.removeAll(where: { $0 == section })
//            print("HiddenSections: \(hiddenSections)")
//        }
//
//        if self.tableView(tableView, titleForHeaderInSection: section)?.contains("Completed") ?? false {
//            isCompletedHidden = !isCompletedHidden
//        }
//
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
//}

extension AssignmentViewController {
    override func reloadAssignment(withDueDate dueDate: Date?, _ assignment: Assignment) {
        super.reloadAssignment(withDueDate: dueDate, assignment)
        delegate?.reloadClass(`class`)
    }
}
