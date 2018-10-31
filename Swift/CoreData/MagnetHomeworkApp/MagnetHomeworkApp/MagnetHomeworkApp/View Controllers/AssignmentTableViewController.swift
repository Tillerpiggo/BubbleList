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
        let fetchRequest: NSFetchRequest<Assignment
    }
}
