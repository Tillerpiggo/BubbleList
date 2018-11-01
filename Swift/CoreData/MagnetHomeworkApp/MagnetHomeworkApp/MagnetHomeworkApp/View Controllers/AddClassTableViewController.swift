//
//  AddClassTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/28/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AddClassTableViewControllerDelegate {
    func addedClass(_ class: Class)
}

class AddClassTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    public var delegate: AddClassTableViewControllerDelegate?
    var coreDataController: CoreDataController!
    var cloudController: CloudController!
    
    // MARK: - IBOutlets:
    
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.becomeFirstResponder()
    }
    
    // MARK:- IBActions
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapepd(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        updateSaveButton()
        print("Text Field Text Changed")
    }
    
    // MARK: - Helper Methods
    
    private func save() {
        let newClass = Class(withName: nameTextField.text ?? "", managedContext: coreDataController.managedContext, zoneID: cloudController.zoneID)
        delegate?.addedClass(newClass)
    }
    
    private func updateSaveButton() {
        let nameText = nameTextField.text ?? ""
        saveButton.isEnabled = !nameText.isEmpty
    }
    
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
