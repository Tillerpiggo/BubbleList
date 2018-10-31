//
//  AddAssignmentTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

protocol AddAssignmentTableViewControllerDelegate {
    func addedAssignment(_ assignment: Assignment)
}

class AddAssignmentTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var delegate: AddAssignmentTableViewControllerDelegate?
    var coreDataController: CoreDataController!
    var cloudController: CloudController!
    var owningClass: Class!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        
        updateSaveButton()
    }
    
    // MARK: - IBActions
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        save()
        saveButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    // MARK: - Delegate:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func save() {
        let zoneID = owningClass.isUserCreated ? cloudController.zoneID : owningClass.ckRecord.recordID.zoneID
        let newAssignment = Assignment(withText: textField.text ?? "", managedContext: coreDataController.managedContext, owningClass: owningClass.ckRecord, zoneID: zoneID)
        delegate?.addedAssignment(newAssignment)
    }
    
    private func updateSaveButton() {
        let text = textField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
