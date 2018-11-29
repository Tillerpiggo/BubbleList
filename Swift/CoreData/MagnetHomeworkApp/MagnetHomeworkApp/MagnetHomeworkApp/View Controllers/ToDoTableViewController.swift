//
//  ToDoTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/13/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CoreData

class ToDoTableViewController: AddObjectViewController {
    
    var coreDataController: CoreDataController!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Assignment> = {
        let fetchRequest: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        let sortBySectionNumber = NSSortDescriptor(key: #keyPath(Assignment.dueDateSectionNumber), ascending: true)
        let sortByDueDate = NSSortDescriptor(key: #keyPath(Assignment.dueDate), ascending: true)
        let sortByCreationDate = NSSortDescriptor(key: #keyPath(Assignment.creationDate), ascending: true)
        fetchRequest.sortDescriptors = [sortBySectionNumber, sortByDueDate, sortByCreationDate]
        fetchRequest.fetchBatchSize = 20 // TODO: May need to adjust
        
        let isInSectionPredicate = NSPredicate(format: "dueDate >= %@", Date.tomorrow as CVarArg)
        fetchRequest.predicate = isInSectionPredicate
        
        let fetchedResultsController = NSFetchedResultsController (
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataController.managedContext,
            sectionNameKeyPath: #keyPath(Assignment.dueDateSection),
            cacheName: "ToDo" // May have to change...
        )
        
        //fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        return fetchedResultsController
    }()
    
    func refreshFetchedResultsController(withSection section: String) {
        let isInSectionPredicate: NSPredicate
        
        switch section {
        case "Due Tomorrow":
            isInSectionPredicate = NSPredicate(format: "dueDate <= %@", Date.tomorrow as CVarArg)
        case "Due This Week":
            isInSectionPredicate = NSPredicate(format: "dueDate <= %@", Date.thisFriday as CVarArg)
        default:
            isInSectionPredicate = NSPredicate(value: true)
        }
        
        fetchedResultsController.fetchRequest.predicate = isInSectionPredicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configureNavigationBar() {
//        // GRADIENT
//        let colors: [UIColor] = [.lightColor, .darkColor]
//        navigationController?.navigationBar.setGradientBackground(colors: colors)
        
        navigationController?.navigationBar.barTintColor = .navigationBarTintColor
        
        // TINT COLOR
        navigationController?.navigationBar.tintColor = .tintColor
        
        // TITLE COLOR
        let textAttributes: [NSAttributedString.Key: UIColor]  = [NSAttributedString.Key.foregroundColor: .textColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

}

extension ToDoTableViewController: UITableViewDelegate, UITableViewDataSource {
    
}
